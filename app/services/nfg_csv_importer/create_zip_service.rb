# frozen_string_literal: true

require 'open-uri'

module NfgCsvImporter
  class CreateZipService
    def initialize(model:, attr:, user_id:)
      @model = model
      @attr = attr
      @user_id = user_id
    end

    def call
      tmp_user_folder =  "tmp/archive_#{@user_id}"
      tmp_model_folder = "#{tmp_user_folder}/#{tmp_dir_name}"
      FileUtils.remove_dir(tmp_user_folder) if Dir.exists?(tmp_user_folder)
      FileUtils.mkdir_p(tmp_model_folder)
      submitted_files = @model.send(@attr)
      if submitted_files&.any?
        submitted_files.each do |document|
          filename = "#{document.blob.filename.base}_#{document.blob.id}.#{document.blob.filename.extension}"
          store_documents_in_tmp_user_folder(document, tmp_model_folder, filename)
        end
        create_zip_from_tmp_user_folder(tmp_model_folder)
        NfgCsvImporter::DeleteZipJob.perform_in(60.minutes, tmp_user_folder)
        return "#{tmp_model_folder}.zip"
      end
      nil
    end

    private

    def store_documents_in_tmp_user_folder(document, tmp_model_folder, filename)
      download = open(document.service_url)
      IO.copy_stream(download, "#{tmp_model_folder}/#{filename}")
    end

    def create_zip_from_tmp_user_folder(tmp_model_folder)
      `zip -rj "#{tmp_model_folder}.zip" "#{tmp_model_folder}"`
    end

    def tmp_dir_name
      "#{@model.class.name}_#{@model.id}"
    end
  end
end
