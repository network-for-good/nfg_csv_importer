module NfgCsvImporter
  class CalculateImportStatisticsJob < ActiveJob::Base
    queue_as NfgCsvImporter.configuration.high_priority_queue_name || :high_priority

    def perform(import_id, starting_row = 2)
      import = NfgCsvImporter::Import.find(import_id)
      import.calculate_statistics
    end
  end
end
