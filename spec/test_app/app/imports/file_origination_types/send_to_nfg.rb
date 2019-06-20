# frozen_string_literal: true

module FileOriginationTypes
  class SendToNfg < FileOriginationTypes::Base

    class << self
      def name
        'Send To Network for Good for Processing'
      end

      def logo_path
        "nfg_csv_importer/file_origination_types/send_us_files.png"
      end

      def description
        'Not sure if you got the chops to do your own import? Let NFG handle the import for you.'
      end
    end
  end
end