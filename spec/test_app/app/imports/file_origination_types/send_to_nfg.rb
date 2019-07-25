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

      def requires_post_processing_file
        false
      end

      def collect_note_with_pre_processing_files
        # for send to nfg, we want the user to tell us about
        # the files they are uploading
        true
      end

      def post_preprocessing_upload_hook
        ->(import, options = {}) {
          # here is where DM should send the email to the import team.
          # We don't do it here because there was no reason to create a dummy
          # mailer to do that when this test app will never actually send
          # that message.
          import.complete!
          OpenStruct.new({ status: :success })
        }
      end
    end
  end
end