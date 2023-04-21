require 'sidekiq'

module NfgCsvImporter
  class ProcessImportJob
    include Sidekiq::Worker
    attr_accessor :import

    sidekiq_options(
      { queue: NfgCsvImporter.configuration.high_priority_queue_name }.merge(NfgCsvImporter.configuration.process_import_job_sidekiq_options)
    )

    def perform(import_id)
      self.import = NfgCsvImporter::Import.find(import_id)

      import.with_lock do
        if import.queued? || import.requeued? || import.status.nil?
          # If the import has a status of queued or requeued, that means it's safe to start processing it
          log "processing queued import"
          import.processing!

        elsif import.processing?
          # We only want to do this check if the import is being processed. Otherwise,
          # both field values will be nil.
          if import.records_processed > import.number_of_records
            log "import was already completed with processing status. Marking import complete."
            import.complete!
          else
            log "import is already processing. Quitting."
          end
          # If the import has a status of :processing, that means a job is already working on it
          # and we should quit.
          return

        elsif import.complete?
          # If the import has a status of complete, we run the callbacks just to be safe.
          log "import was already marked complete."
          return

        else
          log "THIS SHOULD NEVER HAPPEN"
          return
        end
      end

      # We will only get here if the import originally had a status of queued or requeued
      import_service = import.service

      if import.records_processed.blank?
        log "beginning initial processing"
        import.update(processing_started_at: Time.zone.now)
        NfgCsvImporter::ImportMailer.send_import_result(import).deliver_later
        # the import_service will set this value by default, but we're doing
        # it here for clarity.
        import_service.starting_row = 2
      else
        # If this import has a processed_records value, we start processing from
        # the value of that field + 2, which is the next row (taking into account
        # the header row).
        starting_row = import.records_processed + 2
        import_service.starting_row = starting_row
        log "resuming import from row #{starting_row}"
      end

      errors_csv = import_service.import
      import.set_upload_error_file(errors_csv) if errors_csv.present?

      if $shutdown_pending
        import.lock!.requeued!
        log "Shutdown detected, so quitting gracefully"
        raise Sidekiq::Shutdown
      end

      if import.killed?
        log "import was killed"
        return
      elsif import_service.run_time_limit_reached?
        # We set the import status back to queued here so that the new job will be able to process it.
        import.lock!.requeued!
        log "reached run time limit of #{NfgCsvImporter.configuration.max_run_time} at row #{import_service.current_row}"
        NfgCsvImporter::ProcessImportJob.perform_async(import_id)
      else
        import.lock!.complete!
        NfgCsvImporter::ImportMailer.send_import_result(import).deliver_later
        log "completed import"
      end
    end

    private

    def log(arg)
      msg = "#{self.class.name} #{import.id} with status #{import.status}: #{arg}"
      if ENV['SPEC_DEBUG'].present?
        p msg
      else
        Sidekiq.logger.info msg
      end
    end
  end
end
