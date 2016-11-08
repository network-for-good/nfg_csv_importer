module NfgCsvImporter
  class ImportDefinitionDetails < OpenStruct

    def required_columns
      self["required_columns"] || []
    end

    def optional_columns
      self["optional_columns"] || []
    end

    def default_values
      self["default_values"] || {}
    end

    def alias_attributes
      self["alias_attributes"] || []
    end

    def column_descriptions
      self["column_descriptions"] || {}
    end

    def description
      self["description"] || ""
    end

    def field_aliases
      self["field_aliases"] || {}
    end

    def column_validation_rules
      return @column_validation_rules if @column_validation_rules

      @column_validation_rules = (self["column_validation_rules"] || []).map do |rule|
        NfgCsvImporter::ColumnValidator.new(rule)
      end

      @column_validation_rules << NfgCsvImporter::ColumnValidator.new(type: "all",
                                                                      fields: required_columns,
                                                                      message: "At least one of the following required columns are missing: #{required_columns}") if required_columns.present?
      @column_validation_rules
    end
  end
end