require 'sidekiq'

module NfgCsvImporter
  class ProcessImportJob
    include Sidekiq::Worker

    sidekiq_options queue: (NfgCsvImporter.configuration.high_priority_queue_name || :high_priority), retry: false

    def perform(import_id, starting_row = 2)
      import = NfgCsvImporter::Import.find(import_id)
      import.processing!

      if starting_row == 2
        NfgCsvImporter::ImportMailer.send_import_result(import).deliver_now
        import.update(processing_started_at: Time.zone.now)
      end

      import_service = import.service
      import_service.starting_row = starting_row
      errors_csv = import_service.import
      import.set_upload_error_file(errors_csv) if errors_csv.present?

      if import_service.run_time_limit_reached?
        Rails.logger.info "ProcessImportJob #{import_id}: reached run time limit of #{NfgCsvImporter.configuration.max_run_time} at row #{import_service.current_row}"
        NfgCsvImporter::ProcessImportJob.perform_async(import_id, import_service.current_row)
      else
        import.complete!
        import.update(processing_finished_at: Time.zone.now)
        NfgCsvImporter::ImportMailer.send_import_result(import).deliver_now
        Rails.logger.info "ProcessImportJob #{import_id}: completed import"
      end
    end
  end
end
