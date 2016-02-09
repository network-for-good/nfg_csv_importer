module NfgCsvImporter
  class ProcessImportJob < ActiveJob::Base
    queue_as :imports

    def perform(*args)
      import = NfgCsvImporter::Import.find(args.first)
      import.processing!

      import_service = import.service
      errors_csv = import_service.import
      unless errors_csv.nil?
        import.upload_error_file(errors_csv)
      end

      import.update(
        number_of_records: import_service.no_of_records,
        number_of_records_with_errors: import_service.no_of_error_records,
        status: :complete
      )
      NfgCsvImporter::ImportMailer.send_import_result(import).deliver
    end
  end
end
