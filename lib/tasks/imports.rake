namespace :nfg_csv_importer do
  namespace :imports do
    desc "Updates the fields_mapping hash for all imports that currently don't have any fields mapping"
    task set_fields_mapping: :environment do
      Rails.logger.info "-------> Entering fields mapping task"
      NfgCsvImporter::Import.all.each do |import|
        Rails.logger.info  "-------> Starting fields mapping for import: #{ import.id }"

        import.import_file_name ||= import.import_file.send(:original_filename)
        import.import_file_name ||= import["import_file"]
        import.processing_started_at ||= import.created_at
        import.processing_finished_at ||= import.updated_at

        begin
          import.fields_mapping ||= NfgCsvImporter::FieldsMapper.new(import).call
        rescue Exception => e
          Rails.logger.error  "-------> Fields mapping failed for import: #{ import.id } with #{ e.message }"
        end

        # in case we couldn't map the fields above, we just use the headers as the mappings
        import.fields_mapping ||= import.header.inject({}) { |hsh, field| hsh[field] = field; hsh }

        import.save

        Rails.logger.info  "-------> Finished fields mapping for import: #{ import.id }"
      end
      Rails.logger.info  "-------> Finished fields mapping"
    end
  end
end