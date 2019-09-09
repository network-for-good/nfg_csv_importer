module NfgCsvImporter
  class CreateZipService
    def initialize(model:, attr:, user_id:)
      @model = model
      @attr = attr
      @user_id = user_id
    end

    def call
      tmp_user_folder =  "tmp/archive_#{@user_id}"
      tmp_model_folder = "#{tmp_user_folder}/#{@model.class.name}_#{@model.id}"
      FileUtils.remove_dir(tmp_user_folder) if Dir.exists?(tmp_user_folder)
      FileUtils.mkdir_p(tmp_model_folder) unless Dir.exists?(tmp_model_folder)
      submitted_files = @model.send(@attr)
      if submitted_files&.any?
        submitted_files.each do |document|
          filename = "#{document.blob.id}_#{document.blob.filename}"
          create_tmp_user_folder_and_store_documents(document, tmp_model_folder, filename)
          create_zip_from_tmp_user_folder(tmp_model_folder, filename)
        end
        NfgCsvImporter::DeleteZipJob.set(wait: 60.minutes).perform_later(tmp_user_folder)
        return tmp_model_folder
      end
      nil
    end

    private

    def create_tmp_user_folder_and_store_documents(document, tmp_model_folder, filename)
      File.open(File.join(tmp_model_folder, filename), 'wb') do |file|
        document.download { |chunk| file.write(chunk) }
      end
    end

    def create_zip_from_tmp_user_folder(tmp_model_folder, filename)
      Zip::File.open("#{tmp_model_folder}.zip", Zip::File::CREATE) do |zf|
        zf.add(filename, "#{tmp_model_folder}/#{filename}")
      end
    end
  end
end
