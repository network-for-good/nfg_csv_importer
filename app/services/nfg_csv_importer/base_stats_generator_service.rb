# frozen_string_literal: true

module NfgCsvImporter
  class BaseStatsGeneratorService
    attr_accessor :spreadsheet, :row_conversion_method

    def initialize(spreadsheet:, row_conversion_method:)
      @spreadsheet = spreadsheet
      @row_conversion_method = row_conversion_method
    end

    def call
      raise "#call must be implemented in the child class"
    end
  end
end
