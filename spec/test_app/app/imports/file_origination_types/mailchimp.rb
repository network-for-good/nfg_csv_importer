module FileOriginationTypes
  class Mailchimp < FileOriginationTypes::Base

    class << self
      def name
        'Mailchimp'
      end

      def logo_path
        "nfg_csv_importer/file_origination_types/mailchimp.png"
      end

      def description
        'One button click to bring over everyone on your mailing list.'
      end
    end
  end
end