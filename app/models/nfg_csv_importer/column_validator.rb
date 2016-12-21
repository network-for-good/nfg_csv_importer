module NfgCsvImporter
  # receives a hash containing the following:
  #   type: String - The type of rule. Can be 'any' or 'all_if_any'
  #   fields: Array - The list of fields to be validated. Each field should be a string
  #   message: String - The message returned if the validation fails

  # A 'any' validation ensures that at least one of the fields in the array of
  # fields is included in the import definition

  # A 'all_if_any' validation requires that all of the fields in the array be included
  # if any of them are included

  # A 'all' validation requires that all of the fields in the array be included
  class ColumnValidator

    attr_accessor :fields_mapping, :type, :fields, :message
    def initialize(args)
      @type = args[:type]
      @fields = args[:fields]
      @message = args[:message] || ""
      raise ArgumentError.new("You must supply a rule type ('any', 'all_if_any') but no type was included #{ args}") unless type
      raise ArgumentError.new("You must supply the rule fields (fields: ['field 1', 'field 2']) but no fields were included #{ args }") unless fields
    end

    def validate(fields_mapping)
      @fields_mapping = fields_mapping
      self.send "validate_#{type}"
    end

    private

    def validate_any
      fields.select { |field| mapped_to_fields.include?(field) }.any?
    end

    def validate_all
      return fields.map { |field| mapped_to_fields.include?(field) }.all?
    end

    def validate_all_if_any
      if fields.select { |field| mapped_to_fields.include?(field) }.any?
        return fields.map { |field| mapped_to_fields.include?(field) }.all?
      end
      true
    end

    def mapped_to_fields
      (@fields_mapping || {}).values
    end
  end
end