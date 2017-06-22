module NfgCsvImporter
  class MappedField
    attr_accessor :name, :mapped_to
    def initialize(header_column:, field:, fields_that_allow_multiple_mappings: [])
      @name = header_column
      @mapped_to = field
      @fields_that_allow_multiple_mappings = fields_that_allow_multiple_mappings || []
    end

    def status
      return :ignored if mapped_to.present? && mapped_to == ignore_column_value
      return :mapped if mapped_to.present?
      :unmapped
    end

    def dom_id
      name.downcase.gsub(/[^a-z0-9_ ]/, '').gsub(/( )/, '_')
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

    def mergeable?
      @fields_that_allow_multiple_mappings.include?(mapped_to)
    end

    private

    def ignore_column_value
      NfgCsvImporter::Import.ignore_column_value
    end

  end
end
