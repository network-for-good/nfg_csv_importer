# frozen_string_literal: true

module NfgCsvImporter
  module FileOriginationTypes
    class FileOriginationType
      attr_accessor :type_sym, :type_class

      def self.attrs
        [:name, :requires_preprocessing_files, :allowed_import_types, :post_preprocessing_upload_hook, :field_mapping,
                    :requires_post_processing_file, :collect_note_with_pre_processing_files, :logo_path, :description, :skip_steps, :display_mappings]
      end

      def formatted_type_sym
        type_sym.to_s.downcase
      end

      attr_accessor *attrs

      def initialize(file_type_sym, type_klass)
        @type_sym = file_type_sym
        @type_class = type_klass
        self.class.attrs.each do |attr|
          self.send("#{attr}=", type_klass.send(attr))
        end
      end
    end
  end
end
