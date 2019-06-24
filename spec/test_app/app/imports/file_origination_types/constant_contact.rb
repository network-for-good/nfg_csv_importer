module FileOriginationTypes
  class ConstantContact < FileOriginationTypes::Base

    class << self
      def name
        'Constant Contact'
      end

      def logo_path
        "nfg_csv_importer/file_origination_types/constant_contact.png"
      end

      def description
        'Every single contact can be brought over to donor management.'
      end

      def skip_steps
        %i[overview import_type upload_post_processing field_mapping]
      end
    end
  end
end