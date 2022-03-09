# frozen_string_literal: true

module NfgCsvImporter
  class DefaultStatsGeneratorService < NfgCsvImporter::BaseStatsGeneratorService
    def call
      {
        "summary_data" => { "number_of_rows" => spreadsheet&.last_row - 1 },
        "example_rows" => [
                            row_conversion_method&.call(random_row),
                            row_conversion_method&.call(random_row)
                          ]
      }
    end

    private

    def random_row
      Random.new.rand(2..spreadsheet&.last_row)
    end
  end
end
