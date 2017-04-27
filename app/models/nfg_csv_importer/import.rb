module NfgCsvImporter
  class Import < ActiveRecord::Base
    attr_accessor :import_template_id # captures the id of a previous import from which fields mappings should be generated

    STATUSES = [:uploaded, :defined, :queued, :processing, :complete, :deleting, :deleted]

    IGNORE_COLUMN_VALUE = "ignore_column"
    serialize :fields_mapping

    enum status: [:queued, :processing, :complete, :deleting, :deleted, :uploaded, :defined]
    mount_uploader :import_file, ImportFileUploader
    mount_uploader :error_file, ImportErrorFileUploader

    has_many :imported_records, dependent: :destroy
    belongs_to :imported_by, class_name: NfgCsvImporter.configuration.imported_by_class, foreign_key: :imported_by_id
    belongs_to :imported_for, class_name: NfgCsvImporter.configuration.imported_for_class, foreign_key: :imported_for_id

    validates_presence_of :import_file, :import_type, :imported_by_id, :imported_for_id
    validate :import_validation

    scope :order_by_recent, lambda { order("updated_at DESC") }

    delegate :description, :required_columns, :optional_columns, :column_descriptions, :transaction_id,
      :header, :missing_required_columns, :import_class_name, :headers_valid?, :valid_file_extension?,
      :import_model, :unknown_columns, :all_valid_columns, :field_aliases, :first_x_rows,
      :invalid_column_rules, :column_validation_rules, :can_be_viewed_by,
      :fields_that_allow_multiple_mappings, :can_be_deleted_by?, :to => :service

    def self.ignore_column_value
      IGNORE_COLUMN_VALUE
    end

    def can_be_deleted?(admin)
      uploaded? || (complete? && can_be_deleted_by?(admin))
    end

    def column_stats
      return @stats if @stats
      @stats = {
        column_count: 0,
        unmapped_column_count: 0,
        mapped_column_count: 0,
        ignored_column_count: 0
      }

      mapped_fields.each do |mf|
        @stats[:column_count] += 1
        @stats["#{ mf.status }_column_count".to_sym] += 1
      end
      @stats
    end

    def duplicated_field_mappings
      return {} unless fields_mapping.present?
      fields = fields_mapping.values
      duplicates = fields.select { |f|  has_a_non_permitted_duplicate(f, fields) }.uniq
      duplicates.inject({}) do |hsh, dupe_field|
        hsh[dupe_field] = fields_mapping.inject([]) { |arr, (column, field)| arr << column if field == dupe_field; arr }
        hsh
      end
    end

    def header_errors
      return @header_errors if @header_errors
      @header_errors = invalid_column_rules.inject([]) { |hsh, invalid_rule| hsh << invalid_rule.message; hsh }
      @header_errors
    end

    def imported_by_name
      imported_by.try(:name)
    end

    def import_validation
      begin
        errors.add :base, "Import File can't be blank, Please Upload a File" and return false if import_file.blank?
        errors.add :base, "At least one empty column header was detected. Please ensure that all column headers contain a value." if empty_column_headers.present?
        errors.add :base, "The column headers contain duplicate values. Either modify the headers or delete a duplicate column. The duplicates are: #{ duplicated_headers.map { |dupe, columns| "'#{ dupe }' on columns #{ columns.join(' & ') }" }.join("; ") }" if duplicated_headers.present?
      rescue  => e
        errors.add :base, "We weren't able to parse your spreadsheet.  Please ensure the first sheet contains your headers and import data and retry.  Contact us if you continue to have problems and we'll help troubleshoot."
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
        return false
      end
      true
    end

    def mapped_fields(header_column = nil)
      return @mapped_fields if @mapped_fields && !header_column
      # passing in a header column will return the mapped field object for just that header column
      if header_column
        fields_mapping.has_key?(header_column) ? NfgCsvImporter::MappedField.new(
                                                          header_column: header_column,
                                                          field: fields_mapping[header_column],
                                                          fields_that_allow_multiple_mappings: fields_that_allow_multiple_mappings) : nil
      else
        @mapped_fields = fields_mapping.blank? ? [] : fields_mapping.map { |header_column, field| NfgCsvImporter::MappedField.new(
                                                                                                      header_column: header_column,
                                                                                                      field: field, fields_that_allow_multiple_mappings:
                                                                                                      fields_that_allow_multiple_mappings)}
      end
    end

    def maybe_append_to_existing_errors(errors_csv)
      if error_file.present?
        errors_csv = CSV.generate do |csv|
          CSV.parse(error_file.read) { |row| csv << row }
          CSV.parse(errors_csv, headers: true) { |row| csv << row }
        end
      end

      errors_csv
    end

    def process!
      service.import
    end

    def ready_to_import?
      return false if unmapped_columns.present?
      return false if duplicated_field_mappings.present?
      return false unless headers_valid?
      true
    end

    def service
      return @service if @service
      service_class = Object.const_get(service_name) rescue NfgCsvImporter::ImportService
      @service = service_class.new(imported_by: imported_by, imported_for: imported_for, type: import_type, file: import_file, import_record: self)
    end

    def set_upload_error_file(errors_csv)
      errors_csv = maybe_append_to_existing_errors(errors_csv)
      csv_file = FilelessIO.new(errors_csv)
      csv_file.original_filename = "import_error_file.csv"
      self.error_file = csv_file
      self.save!
    end

    def time_zone
      if imported_for.respond_to?(:time_zone) && imported_for.time_zone
        imported_for.time_zone
      else
        'Eastern Time (US & Canada)'
      end
    end

    def unmapped_columns
      mapped_fields.select { |column| column.unmapped? }
    end

    def time_remaining_message
      return 'Unknown' if minutes_remaining < 0
      hours = (minutes_remaining/60).floor
      minutes = (minutes_remaining % 60)
      str = hours > 0 ? "#{ ActionController::Base.helpers.pluralize(hours, "hour")} and " : ""
      str += ActionController::Base.helpers.pluralize(minutes, "minute")
      str
    end

    private

    def service_name
      "#{import_type.capitalize}".classify + "ImportService"
    end

    def empty_column_headers
      header.select { |h| h.blank? }
    end

    def duplicated_headers
      duplicates = header.select { |f|  header.count(f) > 1 }.uniq
      duplicates.inject({}) do |hsh, dupe_field|
        hsh[dupe_field] = header.each.with_index.inject([]) { |arr, (field, index)| arr << (index + 1).to_s26.upcase if field == dupe_field; arr }
        hsh
      end
    end

    def minutes_remaining
      return -1 if number_of_records.nil? || number_of_records == 0
      return -1 if records_processed.nil? || records_processed == 0
      return 0 if records_processed == number_of_records
      return -1 if processing_started_at.nil?
      minutes_processing = (Time.now - processing_started_at)/60
      percent_complete = records_processed.to_f/number_of_records.to_f
      estimated_total = minutes_processing.to_f/percent_complete.to_f
      remaining_minutes = (estimated_total - minutes_processing).floor
    end

    def has_a_non_permitted_duplicate(mapped_field, fields)
      mapped_field.present? &&
      fields.count(mapped_field) > 1 &&
      mapped_field != NfgCsvImporter::Import.ignore_column_value &&
      !field_allowed_to_be_duplicated?(mapped_field)
    end

    def field_allowed_to_be_duplicated?(mapped_field)
      # fields can be duplicated if they are listed in the definition
      # as fields_that_allow_multiple_mappings
      fields_that_allow_multiple_mappings.include?(mapped_field)
    end
  end

  class FilelessIO < StringIO
    attr_accessor :original_filename
  end
end