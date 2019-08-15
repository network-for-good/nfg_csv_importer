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
    # Different file origination types can be added by updating a
    # configuration setting during initialization of the gem:
    #
    # `config.additional_file_orignation_types = [:constant_contact, :paypal]`
    #
    # The NfgImporter::Configuration class gets passed into the Manager
    # class on initialization
    #
    class TypeNotDefinedError < StandardError; end

    class Manager
      DEFAULT_FILE_ORIGINATION_TYPE_SYM = :self_import_csv_xls

      attr_accessor :host_config

      def self.default_file_origination_type
        file_type_manager = self.new(NfgCsvImporter.configuration)
        file_type_manager.type_for(DEFAULT_FILE_ORIGINATION_TYPE_SYM)
      end

      def initialize(config)
        @host_config = config
        require_origination_files
      end

      def types
        return @types if @types
        @types = additional_file_origination_types.map do |file_type|
          NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(file_type, file_origination_constant(file_type))
        end
        @types << NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(DEFAULT_FILE_ORIGINATION_TYPE_SYM, "NfgCsvImporter::FileOriginationTypes::#{DEFAULT_FILE_ORIGINATION_TYPE_SYM.to_s.camelcase}".constantize)
      end

      def type_for(type_name)
        types.select { |t| t.type_sym == type_name.try(:to_sym) }.first
      end

      private

      def require_origination_files
        require_dependency File.expand_path(File.join(File.dirname(__FILE__), DEFAULT_FILE_ORIGINATION_TYPE_SYM.to_s))
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

      def all_file_origination_types
        additional_file_origination_types + [DEFAULT_FILE_ORIGINATION_TYPE_SYM]
      end

      def additional_file_origination_types
        # these are configured in the host app. By default, there
        # are no additional_file_origination_types. When there are no
        # additional_file_origination_types configured, the file origination
        # selection step is skipped and the user is taken directly to the upload
        # page
        (host_config.additional_file_origination_types || [])
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