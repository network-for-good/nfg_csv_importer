module NfgCsvImporter
  class DeleteZipJob < ActiveJob::Base
    queue_as :low_priority

    def perform(tmp_user_folder, guard_minutes = 10)
      return unless Dir.exists?(tmp_user_folder)
      # we do not want to delete a file if it was created moments ago
      return if File.ctime(tmp_user_folder) > guard_minutes.to_i.minutes.ago

      FileUtils.remove_dir(tmp_user_folder)
    end
  end
end
