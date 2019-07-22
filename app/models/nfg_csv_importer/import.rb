module NfgCsvImporter
  class Import < ActiveRecord::Base
    attr_accessor :import_template_id # captures the id of a previous import from which fields mappings should be generated

    include NfgOnboarder::OnboardableOwner
    include NfgCsvImporter::Concerns::ImportServiceable
    include NfgCsvImporter::Concerns::ImportFileValidateable

    # These statuses set as constants
    # are used as status "hooks" for UX workflows
    #
    # ex: sending emails to the imported_by recipient at certain stages of import processing.
    PROCESSING_STATUS = :processing
    QUEUED_STATUS = :queued
    COMPLETED_STATUS = :complete

    STATUSES = [:pending, :uploaded, :defined, QUEUED_STATUS, PROCESSING_STATUS, COMPLETED_STATUS, :deleting, :deleted]

    IGNORE_COLUMN_VALUE = "ignore_column"
    serialize :fields_mapping
    serialize :statistics, JSON

    enum status: [:queued, :processing, :complete, :deleting, :deleted, :uploaded, :defined, :pending]
    mount_uploader :import_file, ImportFileUploader
    mount_uploader :error_file, ImportErrorFileUploader

    has_many_attached :pre_processing_files

    has_many :imported_records, dependent: :destroy
    belongs_to :imported_by, class_name: NfgCsvImporter.configuration.imported_by_class, foreign_key: :imported_by_id
    belongs_to :imported_for, class_name: NfgCsvImporter.configuration.imported_for_class, foreign_key: :imported_for_id

    validates_presence_of :imported_by_id, :imported_for_id, if: :run_validations?
    validates_presence_of :import_file, if: :validate_import_file_and_type
    validates_presence_of :import_type, if: :validate_import_file_and_type

    # For backwards compatibility (prior to using the onboarder),
    # we only run import validations on create and if we are
    # running all of the other validations. Most of these validations
    # are happening in the onboarders forms, but in case we need to
    # create an import file outside of that, we can still validate
    # the import file.
    validate :import_validation, on: [:create], if: :run_validations?
    validate :import_file_extension_validation, on: [:create], if: :run_validations?

    scope :order_by_recent, lambda { order("updated_at DESC") }

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

    def file_origination_type
      file_type_manager.type_for(file_origination_type_name)
    end

    def header_errors
      return @header_errors if @header_errors
      @header_errors = invalid_column_rules.inject([]) { |hsh, invalid_rule| hsh << invalid_rule.message; hsh }
      @header_errors
    end

    def imported_by_name
      imported_by.try(:name)
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

    def set_upload_error_file(errors_csv)
      errors_csv = maybe_append_to_existing_errors(errors_csv)
      csv_file = FilelessIO.new(errors_csv)
      csv_file.original_filename = "import_error_file.csv"
      self.error_file = csv_file
      self.save!
    end

    def statistics_and_examples(update_stats: false)
      return statistics if statistics.present? && !update_stats
      temp_stats = generate_stats_and_examples
      update(statistics: temp_stats)
      temp_stats
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

    def default_onboarder
      # this is overriding onboardable_owner
      "import_data_onboarder"
    end

    private

    def field_allowed_to_be_duplicated?(mapped_field)
      # fields can be duplicated if they are listed in the definition
      # as fields_that_allow_multiple_mappings
      fields_that_allow_multiple_mappings.include?(mapped_field)
    end

    def file_type_manager
      NfgCsvImporter::FileOriginationTypes::Manager.new(NfgCsvImporter.configuration)
    end

    def file_origination_type_name
      self["file_origination_type"]
    end

    def has_a_non_permitted_duplicate(mapped_field, fields)
      mapped_field.present? &&
      fields.count(mapped_field) > 1 &&
      mapped_field != NfgCsvImporter::Import.ignore_column_value &&
      !field_allowed_to_be_duplicated?(mapped_field)
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

    def run_validations?
      # when the import file is still pending we don't have to worry
      # about whether its required attributes are present or any other
      # validations as that will be the responsibility of the onboarding
      # forms
      return false if status == 'pending'
      true
    end

    def validate_import_file_and_type
      run_validations? &&
        #  to be consistent with imports prior to adding file origination
        # types, assume that validations should be run when there is no
        # file origination type, otherwise, we defer to the file origination
        # type
        (file_origination_type.nil? || file_origination_type&.requires_post_processing_file)
    end
  end

  class FilelessIO < StringIO
    attr_accessor :original_filename
  end
end
