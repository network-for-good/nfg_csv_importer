# frozen_string_literal: true

module FileOriginationTypes
  class Paypal < FileOriginationTypes::Base

    class << self
      def name
        'PayPal'
      end

      def logo_path
        "nfg_csv_importer/file_origination_types/paypal.png"
      end

      def description
        'Instantly import all of your donors and donations.'
      end
    end
  end
end