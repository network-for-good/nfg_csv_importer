module NfgCsvImporter
  class Configuration
    attr_accessor :imported_for_class, :imported_by_class, :base_controller_class,
                  :from_address, :reply_to_address, :imported_for_subdomain, :max_run_time, :additional_file_origination_types

    def imported_for_field
      (imported_for_class.downcase + "_id")
    end
  end
end