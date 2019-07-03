module NfgCsvImporter
  class FieldsMapper
    attr_accessor :import, :mapped_fields

    delegate :header, :all_valid_columns, :field_aliases, to: :import

    def initialize(import)
      @import = import
      @mapped_fields = empty_column_headers_mappings
    end

    def call
      mapped_fields.merge(column_headers_mapper)
    end

    private

    def empty_column_headers_mappings
      import.header.inject({}) { |hsh, elem| hsh[elem] = nil; hsh }
    end

    def column_header_mapped_to_field_names(header_column)
      columns_for_mapping.detect { |field| field == header_column.downcase }
    end

    def column_header_mapped_to_humanized_field_names(header_column)
      columns_for_mapping.detect { |field| field.humanize.downcase == header_column.downcase }
    end

    def column_header_mapped_to_un_underscored_field_names(header_column)
      columns_for_mapping.detect { |field| field.gsub("_", "") == header_column.downcase }
    end

    def column_header_mapped_to_previous_import_template(header_column)
      mapped_fields_from_template[header_column]
    end

    def column_header_mapped_to_aliases(header_column)
      # each alias should be a hash with the field
      # name as the key and an array of aliases as the value
      # i.e. "first_name" => ["first", "donor first name", "contact first name"]
      field = nil
      aliases_for_mapping.each do |f, alias_values|
        field_regex = alias_values.respond_to?(:join) ? alias_values.join('|') : alias_values
        break field = f if header_column.match(/#{ field_regex }/i)
      end
      field
    end

    def column_headers_mapper
      mapped_fields.inject({}) do |hsh, (header_column, field)|
        if field.blank? # we skip any field that has already been mapped
          matching_field = column_header_mapped_to_previous_import_template(header_column)
          matching_field = column_header_mapped_to_field_names(header_column) unless matching_field.present?
          matching_field = column_header_mapped_to_humanized_field_names(header_column) unless matching_field.present?
          matching_field = column_header_mapped_to_un_underscored_field_names(header_column) unless matching_field.present?
          matching_field = column_header_mapped_to_aliases(header_column) unless matching_field.present?
          hsh[header_column] = matching_field if matching_field
        end
        hsh
      end
    end

    def columns_for_mapping
      all_valid_columns || []
    end

    def aliases_for_mapping
      field_aliases || {}
    end

    def import_as_template
      @import_as_template ||= imported_for.imports.find_by(id: import.import_template_id)
    end

    def mapped_fields_from_template
      return {} unless import.import_template_id
      return {} unless import.imported_for
      return {} unless import_as_template
      import_as_template.fields_mapping
    end

    def imported_for
      import.imported_for
    end
  end
end
