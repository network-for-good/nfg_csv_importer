module NfgCsvImporter
  class ProcessImportJob < ActiveJob::Base
    queue_as :imports

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
        NfgCsvImporter::ProcessImportJob.perform_later(import_id, import_service.current_row)
      else
        import.complete!
        import.update(processing_finished_at: Time.zone.now)
        NfgCsvImporter::ImportMailer.send_import_result(import).deliver_now
        Rails.logger.info "ProcessImportJob #{import_id}: completed import"
      end
    end
  end
end
