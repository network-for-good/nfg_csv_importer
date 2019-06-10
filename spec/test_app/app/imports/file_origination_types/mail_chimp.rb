module FileOriginationTypes
  class MailChimp < FileOriginationTypes::Base

    class << self
      def logo_path
        "nfg_csv_importer/pre_processing_types/mailchimp.png"
      end

      def description
        'One button click to bring over everyone on your mailing list.'
      end
    end
  end
end