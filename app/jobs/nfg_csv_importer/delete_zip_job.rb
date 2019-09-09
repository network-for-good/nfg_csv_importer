module NfgCsvImporter
  class DeleteZipJob < ActiveJob::Base
    queue_as :temp_zip_deletions

    def perform(tmp_user_folder)
      FileUtils.remove_dir(tmp_user_folder) if Dir.exists?(tmp_user_folder)
    end
  end
end
