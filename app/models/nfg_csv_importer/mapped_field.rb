module NfgCsvImporter
  class MappedField
    attr_accessor :name, :mapped_to
    def initialize(header_column:, field:)
      @name = header_column
      @mapped_to = field
    end

    def status
      return :ignored if mapped_to.present? && mapped_to == ignore_column_value
      return :mapped if mapped_to.present?
      :unmapped
    end

    def mapped?
      status == :mapped
    end

    def unmapped?
      status == :unmapped
    end

    def ignored?
      status == :ignored
    end

    private

    def ignore_column_value
      NfgCsvImporter::Import.ignore_column_value
    end

  end
end