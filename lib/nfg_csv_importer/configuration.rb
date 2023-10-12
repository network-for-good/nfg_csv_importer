# frozen_string_literal: true

module NfgCsvImporter
  class Configuration
    attr_accessor :imported_for_class, :imported_by_class, :base_controller_class,
                  :from_address, :reply_to_address, :imported_for_subdomain, :max_run_time, :additional_file_origination_types,
                  :high_priority_queue_name, :default_queue_name, :disable_import_initiation_message, :max_number_of_rows_allowed
    attr_writer :allowed_file_origination_types_to_bypass_max_row_limit

    def allowed_file_origination_types_to_bypass_max_row_limit
      @allowed_file_origination_types_to_bypass_max_row_limit || []
    end

    def imported_for_field
      (imported_for_class.downcase + "_id")
    end
  end
end
