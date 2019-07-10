# frozen_string_literal: true

module NfgCsvImporter
  class DefaultStatsGeneratorService < NfgCsvImporter::BaseStatsGeneratorService
    def call
      {
        "summary_data" => { "number_of_rows" => spreadsheet&.last_row - 1 },
        "example_rows" => [
                            row_conversion_method&.call(2),
                            row_conversion_method&.call(4)
                          ]
      }
    end
  end
end
