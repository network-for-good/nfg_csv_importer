module NfgCsvImporter
  class Configuration
    attr_accessor :imported_for_class, :imported_by_class, :base_controller_class,
                  :from_address, :reply_to_address, :imported_for_subdomain, :max_run_time, :additional_file_origination_types,
                  :high_priority_queue_name, :default_queue_name, :disable_import_initiation_message, :max_number_of_rows_allowed

    def imported_for_field
      (imported_for_class.downcase + "_id")
    end
  end
end
