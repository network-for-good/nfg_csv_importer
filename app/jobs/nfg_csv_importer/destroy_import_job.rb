module NfgCsvImporter
  class DestroyImportJob < ActiveJob::Base
    queue_as :import_deletions

    def perform(*args)
      batch = args.first
      import = NfgCsvImporter::Import.find(args.last)
      import.deleting!
      processing_final_batch = import.imported_records.size == batch.size
      batch.each do |imported_record_id|
        imported_record = NfgCsvImporter::ImportedRecord.find(imported_record_id)
        imported_record.destroy
      end

      if processing_final_batch
        NfgCsvImporter::ImportMailer.send_destroy_result(import)
        import.deleted!
      end
    end
  end
end
