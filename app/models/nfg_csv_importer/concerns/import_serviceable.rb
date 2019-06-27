module NfgCsvImporter
  module Concerns
    module ImportServiceable
      # This concern provides the host object with methods
      # related to the import service.
      extend ActiveSupport::Concern

      included do
        delegate :description, :required_columns, :optional_columns, :column_descriptions, :transaction_id,
          :header, :missing_required_columns, :import_class_name, :headers_valid?, :valid_file_extension?,
          :import_model, :unknown_columns, :all_valid_columns, :field_aliases, :first_x_rows,
          :invalid_column_rules, :column_validation_rules, :can_be_viewed_by,
          :fields_that_allow_multiple_mappings, :can_be_deleted_by?, :attached_file, :to => :service
      end

      def service
        return @service if @service
        service_class = Object.const_get(service_name) rescue NfgCsvImporter::ImportService
        @service = service_class.new(imported_by: imported_by, imported_for: imported_for, type: import_type, file: import_file, import_record: self)
      end

      def service_name
        "#{import_type.capitalize}".classify + "ImportService"
      end

      def time_zone
        if imported_for.respond_to?(:time_zone) && imported_for.time_zone
          imported_for.time_zone
        else
          'Eastern Time (US & Canada)'
        end
      end
    end
  end
end