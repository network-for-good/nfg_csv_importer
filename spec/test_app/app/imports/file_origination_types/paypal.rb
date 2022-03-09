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
        'Import all of your donors and donations from your PayPal account.'
      end

      def skip_steps
        %i[overview import_type upload_post_processing field_mapping]
      end

      def post_preprocessing_upload_hook
        -> (import, options = {}) { PayPalPreprocessorService.new(import).process }
      end

      def display_mappings
        false
      end
    end
  end
end