module NfgCsvImporter
  class CalculateImportStatisticsJob < ActiveJob::Base
    queue_as :imports

    def perform(import_id, starting_row = 2)
      import = NfgCsvImporter::Import.find(import_id)
      import.calculate_statistics
    end
  end
end
