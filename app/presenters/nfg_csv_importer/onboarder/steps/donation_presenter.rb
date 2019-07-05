module NfgCsvImporter
  # This needs to inherit from GemPresenter when Imports are real.
  #
  # I anticipate we'll write an ImportResultsPresenter
  # and the preview will inherit or overwrite the output methods for the actual output page. They are the same layout with different info coming in.
  module Onboarder
    module Steps
      class DonationPresenter < NfgCsvImporter::Onboarder::Steps::PreviewConfirmationPresenter

        attr_accessor :preview_records

        def humanized_card_header_icon
          'dollar'
        end

        def humanized_card_heading
          amount
        rescue StandardError => e
          Rails.logger.error("Failed to retrieve humanized card heading.  Exception: #{e.message}")
        end

        def humanized_card_heading_caption
          [campaign, donated_at]
        end

        # Anticipating an array of arrays that we loop through.
        # The keyword might then be used to sync up an icon for this data (e.g.: user address = 'house')
        def humanized_card_body
          [{ transaction_id: [transaction_id]},{ note: [note]}]
        end

        private

        def amount
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:amount)) || ""
        end

        def transaction_id
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:transaction_id)) || ""
        end

        def donated_at
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:donated_at)) || ""
        end

        def campaign
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:campaign)) || ""
        end

        def note
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:note)) || ""
        end

        def preview_template_service
          NfgCsvImporter::PreviewTemplateService.new(import: view.import)
        end
      end
    end
  end
end
