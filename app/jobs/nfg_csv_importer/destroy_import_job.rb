module NfgCsvImporter
  class DestroyImportJob < ActiveJob::Base
    queue_as :import_deletions

    def perform(*args)
      batch = args.first
      import = NfgCsvImporter::Import.find(args.last)
      @stats = {}
      batch.each do |imported_record_id|
        imported_record = NfgCsvImporter::ImportedRecord.find(imported_record_id) rescue next
        next unless imported_record.created?
        imported_record.destroy_importable!
        imported_record.destroy_stats.each do |key, value|
          if @stats.has_key?(key)
            @stats[key] << value
          else
            @stats[key] = [value]
          end
        end
      end

      Rails.logger.info "Batch finished: #{@stats}"

      import.reload
      if import.imported_records.where(deleted: true).count == import.imported_records.count
        NfgCsvImporter::ImportMailer.send_destroy_result(import).deliver
        import.update_attribute(:status, NfgCsvImporter::Import.statuses[:deleted])
        Rails.logger.info "Final batch for #{import.class} #{import.id} finished processing at #{DateTime.now}"
      end
    end
  end
end
