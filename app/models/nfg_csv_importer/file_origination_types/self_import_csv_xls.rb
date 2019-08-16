module NfgCsvImporter
  module FileOriginationTypes
    class SelfImportCsvXls < ::NfgCsvImporter::FileOriginationTypes::Base

      class << self
        def name
          'Your own spreadsheet'
        end

        def logo_path
          "nfg_csv_importer/file_origination_types/self_import_csv_xls.png"
        end

        def description
          'Import contacts and donations from a csv or xls file.'
        end

        def requires_preprocessing_files
          # If this file origination type expects the user to supply
          # pre-processing files to be worked on by the system or handed
          # off for manual manipulation, return true. Returning false will
          # skip the preprocessing upload
          false
        end

        def skip_steps
          %i[upload_preprocessing]
        end
      end
    end
  end
end