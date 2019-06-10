# frozen_string_literal: true

module NfgCsvImporter
  module FileOriginationTypes
    # The FileOriginationTypes::Manager class is used to manage
    # all aspects of the file origination types that the engine needs
    # in order to operate
    # This includes ensuring that the file type classes are loaded, and that
    # and returning a list of objects that can be used to manage the UI
    # and logic surrounding the origination types
    #
    # It accepts an nfg_csv_importer configuration object
    class TypeNotDefinedError < StandardError; end

    class Manager
      attr_accessor :host_config
      def initialize(config)
        @host_config = config
        require_origination_files
      end

      def types
        return [] if (additional_file_origination_types || []).empty?
        host_config.additional_file_origination_types.map do |file_type|
          NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(file_type, file_origination_constant(file_type))
        end
      end

      private

      def require_origination_files
        return if additional_file_origination_types.nil?
        additional_file_origination_types.each do |file_type|
          begin
            file_origination_constant(file_type)
          rescue NameError
            begin
              require_dependency Rails.root.join("app", "imports", "file_origination_types", file_type.to_s)
            rescue LoadError
              raise NfgCsvImporter::FileOriginationTypes::TypeNotDefinedError.new("You must add the #{file_type.to_s}.rb in the host application's app/imports/file_origination_types folder. It should define the #{ file_origination_constant_string(file_type) } class")
            end
          end
        end
      end

      def additional_file_origination_types
        host_config.additional_file_origination_types
      end

      def file_origination_constant(file_type)
        file_origination_constant_string(file_type).constantize
      end

      def file_origination_constant_string(file_type)
        "::FileOriginationTypes::#{file_type.to_s.camelcase}"
      end
    end
  end
end