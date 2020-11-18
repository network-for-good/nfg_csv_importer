require 'sidekiq'

module NfgCsvImporter
  class ProcessImportJob
    include Sidekiq::Worker

    sidekiq_options queue: (NfgCsvImporter.configuration.high_priority_queue_name || :high_priority), retry: false

    def perform(import_id)
      import = NfgCsvImporter::Import.find(import_id)
      import.processing!
      import_service = import.service

      if import.records_processed.blank?
        NfgCsvImporter::ImportMailer.send_import_result(import).deliver_now
        import.update(processing_started_at: Time.zone.now)
        # the import_service will set this value by default, but we're doing
        # it here for clarity.
        import_service.starting_row = 2
      else
        # If this import has a processed_records, we start processing from
        # the value of that field + 1, which is the next row.
        import_service.starting_row = import.records_processed + 1
      end

      errors_csv = import_service.import
      import.set_upload_error_file(errors_csv) if errors_csv.present?

      if import_service.run_time_limit_reached?
        Rails.logger.info "ProcessImportJob #{import_id}: reached run time limit of #{NfgCsvImporter.configuration.max_run_time} at row #{import_service.current_row}"
        NfgCsvImporter::ProcessImportJob.perform_async(import_id)
      else
        import.complete!
        import.update(processing_finished_at: Time.zone.now)
        NfgCsvImporter::ImportMailer.send_import_result(import).deliver_now
        Rails.logger.info "ProcessImportJob #{import_id}: completed import"
      end
    end
  end
end
