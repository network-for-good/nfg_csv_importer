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
          'Every single contact can be brought over to donor management.'
        end

        def requires_preprocessing_files
          # If this file origination type expects the user to supply
          # pre-processing files to be worked on by the system or handed
          # off for manual manipulation, return true. Returning false will
          # skip the preprocessing upload
          false
        end

        def expects_preprocessing_to_attach_post_processing_file
          # For files that will be preprocessed, there is an expectation that
          # the output will be a postprocessed file that will be attached
          # to the Import record (import.file)
          # If this value is false, the user will be required to supply the
          # post processed file.
          false
        end

        def skip_steps
          %i[upload_preprocessing]
        end
      end
    end
  end
end