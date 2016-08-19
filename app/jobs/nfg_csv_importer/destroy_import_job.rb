module NfgCsvImporter
  class DestroyImportJob < ActiveJob::Base
    queue_as :import_deletions

    def perform(*args)
      batch = args.first
      import = NfgCsvImporter::Import.find(args.last)
      processing_final_batch = import.imported_records.size == batch.size
      batch.destroy_all

      if processing_final_batch
        NfgCsvImporter::ImportMailer.send_destroy_result(import)
        # delete import record here
      end
    end
  end
end
