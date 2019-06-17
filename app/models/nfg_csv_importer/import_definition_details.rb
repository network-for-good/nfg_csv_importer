module NfgCsvImporter
  class ImportDefinitionDetails < OpenStruct
    include NfgCsvImporter::WorkingCode::ImportDefinitionDetailsUpdates

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

    def fields_that_allow_multiple_mappings
      self["fields_that_allow_multiple_mappings"] || []
    end

    def can_be_viewed_by(user)
      return true if can_be_viewed_by_rule.nil?

      return !!can_be_viewed_by_rule unless can_be_viewed_by_rule.respond_to?(:call)

      can_be_viewed_by_rule.call(user)
    end

    # Follows same pattern as can_be_viewed_by - passes user to a proc and lets
    # the parent app decide.
    def can_be_deleted_by?(user)
      return false if can_be_deleted_by_rule.nil?
      return !!can_be_deleted_by_rule unless can_be_deleted_by_rule.respond_to?(:call)
      can_be_deleted_by_rule.call(user)
    end

    def column_validation_rules
      return @column_validation_rules if @column_validation_rules

      @column_validation_rules = (self["column_validation_rules"] || []).map do |rule|
        NfgCsvImporter::ColumnValidator.new(rule)
      end

      @column_validation_rules << NfgCsvImporter::ColumnValidator.new(type: "all",
                                                                      fields: required_columns,
                                                                      message: "You must map columns to all of the following fields: #{required_columns}") if required_columns.present?
      @column_validation_rules
    end

    private

    def can_be_viewed_by_rule
      self["can_be_viewed_by"]
    end

    def can_be_deleted_by_rule
      self["can_be_deleted_by"]
    end
  end
end
