module NfgCsvImporter
  # This needs to inherit from GemPresenter when Imports are real.
  #
  # I anticipate we'll write an ImportResultsPresenter
  # and the preview will inherit or overwrite the output methods for the actual output page. They are the same layout with different info coming in.
  module Onboarder
    module Steps
      class DonationPresenter < NfgCsvImporter::Onboarder::Steps::PreviewConfirmationPresenter

        attr_accessor :preview_records, :preview_template_service

        def humanized_card_header_icon
          'dollar'
        end

        def humanized_card_body_icon(keyword)
          humanized_card_body_symbol(keyword, extant?(keyword))
        end

        def humanized_card_heading
          amount
        rescue StandardError => e
          Rails.logger.error("Failed to retrieve humanized card heading.  Exception: #{e.message}")
        end

        def humanized_card_heading_caption
          [campaign, donated_at, payment_method]
        end

        # Anticipating an array of arrays that we loop through.
        # The keyword might then be used to sync up an icon for this data (e.g.: user address = 'house')
        def humanized_card_body
          [{ transaction_id: [transaction_id]},{ note: [note]}]
        end

        def macro_summary_heading_icon
          'dollar'
        end

        def macro_summary_heading_value
          preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_TOTAL_SUM_KEY) || ""
        end

        def macro_summary_heading
          "Total Est. Donations"
        end

        def macro_summary_charts
          arithmetic = NfgCsvImporter::Utilities::Arithmetic
          total_sum = preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_TOTAL_SUM_KEY)

          non_zero_amount_donations =  preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_NON_ZERO_AMOUNT_DONATIONS_KEY) || ""
          zero_amount_donations =  preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_ZERO_AMOUNT_DONATIONS_KEY) || ""
          [
            { title: "Regular Donations", total: non_zero_amount_donations, percentage: arithmetic.percentage(non_zero_amount_donations, total_sum)  },
            { title: "In-kind Donations", total: zero_amount_donations, percentage: arithmetic.percentage(zero_amount_donations,total_sum) }
          ]
        end

        private

        def amount
          subset_of_records_for_preview&.dig(retrieve_host_specific_key_for(:amount)) || ""
        end

        def transaction_id
          subset_of_records_for_preview&.dig(retrieve_host_specific_key_for(:transaction_id)) || ""
        end

        def donated_at
          subset_of_records_for_preview&.dig(retrieve_host_specific_key_for(:donated_at)) || ""
        end

        def campaign
          subset_of_records_for_preview&.dig(retrieve_host_specific_key_for(:campaign)) || ""
        end

        def note
          subset_of_records_for_preview&.dig(retrieve_host_specific_key_for(:note)) || ""
        end

        def payment_method
          subset_of_records_for_preview&.dig(retrieve_host_specific_key_for(:payment_method)) || ""
        end

        def preview_template_service
          @preview_template_service = NfgCsvImporter::PreviewTemplateService.new(import: view.import)
        end

        def retrieve_host_specific_key_for(nfg_key)
          preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(nfg_key)
        end

        def extant?(keyword)
          respond_to?(keyword.to_sym, :include_private) ? send(keyword).present? : false
        end
      end
    end
  end
end
