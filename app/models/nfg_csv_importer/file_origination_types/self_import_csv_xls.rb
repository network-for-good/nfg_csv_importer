module FileOriginationTypes
  class SelfImportCsvXls < NfgCsvImporter::FileOriginationTypes::Base

    class << self
      def logo_path
        "nfg_csv_importer/file_origination_types/constant_contact.png"
      end

      def description
        'Every single contact can be brought over to donor management.'
      end
    end
  end
end