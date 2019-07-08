# frozen_string_literal: true

module FileOriginationTypes
  class SendToNfg < FileOriginationTypes::Base

    class << self
      def name
        'Send us your files'
      end

      def logo_path
        "nfg_csv_importer/file_origination_types/send_us_files.png"
      end

      def description
        'Not sure if you got the chops to do your own import? Let NFG handle the import for you.'
      end

      def skip_steps
        %i[overview import_type upload_post_processing field_mapping preview_confirmation]
      end

      def post_preprocessing_upload_hook
        ->(import) {
          import.update(import_type: 'individual_donation')
          import.import_file = File.open(Rails.root.join("spec", "fixtures", "temp_import_file.csv"))
          import.complete!
        }
      end
    end
  end
end