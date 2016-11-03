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

    def column_header_mapped_to_aliases(header_column)
      aliases_for_mapping.each do |field, alias_values|
        break field if header_column.match(/#{ alias_values.join('|') }/)
      end
    end

    def column_headers_mapper
      mapped_fields.inject({}) do |hsh, (header_column, field)|
        if field.blank? # we skip any field that has already been mapped
          matching_field =  column_header_mapped_to_field_names(header_column) ||
                            column_header_mapped_to_humanized_field_names(header_column) ||
                            column_header_mapped_to_un_underscored_field_names(header_column) ||
                            column_header_mapped_to_aliases(header_column)
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
  end
end