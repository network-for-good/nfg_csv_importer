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

    def column_validation_rules
      if self["column_validation_rules"].blank?
        []
      else
        raise ArgumentError.new("The column_validation_rules attribute must be an array of hashes") unless self["column_validation_rules"].is_a?(Array)
        self["column_validation_rules"].map do |rule|
          NfgCsvImporter::ColumnValidator.new(rule)
        end
      end
    end
  end
end