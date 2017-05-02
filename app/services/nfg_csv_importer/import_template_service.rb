module NfgCsvImporter
  class ImportTemplateService
    IMPORT_FORMATS = %w{csv}

    attr_accessor :import, :format
    delegate :column_descriptions, :required_columns, :optional_columns, to: :import

    def initialize(import:, format: 'csv')
      unless IMPORT_FORMATS.include?(format)
        raise ArgumentError.new("Only #{IMPORT_FORMATS.join(',')} formats allowed")
      end
      @import = import
      @format = format
    end

    def call
      self.send(format)
    end

    private

    def columns_for_template
      required_columns + optional_columns
    end

    def csv
      CSV.generate(:col_sep => ",") do |csv|
        csv << columns_for_template
        csv << columns_for_template.map do |column|
          description = column_descriptions.fetch(column, "")
          required_columns.include?(column) ? "REQUIRED #{description}" : description
        end
      end
    end
  end
end
