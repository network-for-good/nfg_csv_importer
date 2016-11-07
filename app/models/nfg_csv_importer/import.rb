module NfgCsvImporter
  class Import < ActiveRecord::Base

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

    delegate :description, :required_columns,:optional_columns,:column_descriptions, :transaction_id,
      :header, :missing_required_columns,:import_class_name, :headers_valid?, :valid_file_extension?,
      :import_model, :unknown_columns, :header_has_all_required_columns?, :all_valid_columns, :field_aliases, :first_x_rows, :to => :service

    def self.ignore_column_value
      IGNORE_COLUMN_VALUE
    end

    def can_be_deleted?
      imported_records.created.any? && complete? && !Rails.env.production?
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
      duplicates = fields.select { |f|  fields.count(f) > 1 && f != NfgCsvImporter::Import.ignore_column_value && f.present? }.uniq
      duplicates.inject({}) do |hsh, dupe_field|
        hsh[dupe_field] = fields_mapping.inject([]) { |arr, (column, field)| arr << column if field == dupe_field; arr }
        hsh
      end
    end

    def imported_by_name
      imported_by.try(:name)
    end

    def import_validation
      begin
        errors.add :base, "Import File can't be blank, Please Upload a File" and return false if import_file.blank?
        errors.add :base, "The column headers contain duplicate values. Either modify the headers or delete a duplicate column. The duplicates are: #{ duplicated_headers.map { |dupe, columns| "'#{ dupe }' on columns #{ columns.join(' & ') }" }.join("; ") }" if duplicated_headers.present?
      rescue  => e
        errors.add :base, "File import failed: #{e.message}"
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
        return false
      end
      true
    end

    def mapped_fields(header_column = nil)
      # passing in a header column will return the mapped field object for just that header column
      if header_column
        fields_mapping.has_key?(header_column) ? NfgCsvImporter::MappedField.new(header_column: header_column, field: fields_mapping[header_column]) : nil
      else
        fields_mapping.blank? ? [] : fields_mapping.map { |header_column, field| NfgCsvImporter::MappedField.new(header_column: header_column, field: field)}
      end
    end

    def maybe_append_to_existing_errors(errors_csv)
      if error_file.present?
        errors_csv = CSV.generate(col_sep: "\t") do |csv|
          CSV.parse(error_file.read, col_sep: "\t") { |row| csv << row }
          CSV.parse(errors_csv, headers: true, col_sep: "\t") { |row| csv << row }
        end
      end

      errors_csv
    end

    def ready_to_import?
      return false if unmapped_columns.present?
      return false if duplicated_field_mappings.present?
      collect_header_errors and return false unless headers_valid?
      true
    end

    def service
      service_class = Object.const_get(service_name) rescue NfgCsvImporter::ImportService
      service_class.new(imported_by: imported_by, imported_for: imported_for, type: import_type, file: import_file, import_record: self)
    end

    def set_upload_error_file(errors_csv)
      errors_csv = maybe_append_to_existing_errors(errors_csv)
      csv_file = FilelessIO.new(errors_csv)
      csv_file.original_filename = "import_error_file.xls"
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

    private

    def service_name
      "#{import_type.capitalize}".classify + "ImportService"
    end

    def collect_header_errors
      errors.add :base, "The file contains columns that do not have a corresponding value on the #{import_class_name}. Please remove the column(s) or change their header name to match an attribute name. The column(s) are: #{unknown_columns.join(',')}" unless unknown_columns.empty?
      errors.add :base, "Missing following required columns: #{missing_required_columns}" unless header_has_all_required_columns?
    end

    def duplicated_headers
      duplicates = header.select { |f|  header.count(f) > 1 }.uniq
      duplicates.inject({}) do |hsh, dupe_field|
        hsh[dupe_field] = header.each.with_index.inject([]) { |arr, (field, index)| arr << (index + 1).to_s26.upcase if field == dupe_field; arr }
        hsh
      end
    end
  end

  class FilelessIO < StringIO
    attr_accessor :original_filename
  end
end
