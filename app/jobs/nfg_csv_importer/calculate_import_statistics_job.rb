require 'sidekiq'

module NfgCsvImporter
  class CalculateImportStatisticsJob
    include Sidekiq::Worker

    sidekiq_options queue: (NfgCsvImporter.configuration.high_priority_queue_name || :high_priority)

    def perform(import_id, starting_row = 2)
      import = NfgCsvImporter::Import.find(import_id)
      import.calculate_statistics
    end
  end
end
