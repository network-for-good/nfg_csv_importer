# frozen_string_literal: true

module NfgCsvImporter
  module FileOriginationTypes
    class FileOriginationType
      attr_accessor :name, :requires_preprocessing_files, :allowed_import_types, :post_preprocessing_upload_hook, :field_mapping,
                    :expects_preprocessing_to_attach_post_processing_file, :logo_path, :type_sym, :description, :skip_steps

      def initialize(file_type_sym, type_klass)
        @type_sym = file_type_sym
        @type_klass = type_klass
        self.name = type_klass.name
        self.logo_path = type_klass.logo_path
        self.description = type_klass.description
        self.skip_steps = type_klass.skip_steps
      end
    end
  end
end
