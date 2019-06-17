module NfgCsvImporter
  module WorkingCode

    # Used for adding in some settings for the import definitions, in play on the test_app:
    # spec/test_app/app/imports/import_definition.rb
    module ImportDefinitionDetailsUpdates
      def humanized_data_set
        self["humanized_data_set"] || {}
      end

      def summary_data_set
        self["summary_data_set"] || {}
      end

      def preview_sentence_summary_data_set
        self["preview_sentence_summary_data_set"] || {}
      end
    end
  end
end