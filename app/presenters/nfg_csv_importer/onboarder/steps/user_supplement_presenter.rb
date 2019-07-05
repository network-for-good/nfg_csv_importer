module NfgCsvImporter
  # This needs to inherit from GemPresenter when Imports are real.
  #
  # I anticipate we'll write an ImportResultsPresenter
  # and the preview will inherit or overwrite the output methods for the actual output page. They are the same layout with different info coming in.
  module Onboarder
    module Steps
      class UserSupplementPresenter < NfgCsvImporter::Onboarder::Steps::PreviewConfirmationPresenter
        attr_accessor :preview_records

        def humanized_card_header_icon
          'user'
        end

        def humanized_card_heading
          job_title
        rescue StandardError => e
          Rails.logger.error("Failed to retrieve humanized card heading.  Exception: #{e.message}")
        end

        def humanized_card_heading_caption
          [employer]
        end

        # Anticipating an array of arrays that we loop through.
        # The keyword might then be used to sync up an icon for this data (e.g.: user address = 'house')
        def humanized_card_body
          [{ date_of_birth: [date_of_birth] }]
        end

        def humanized_card_body_icon(keyword)
          super(keyword)
        end

        private

        def job_title
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping
                                                                     .with_indifferent_access.dig(:job_title)) || ""
        end

        def employer
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping
                                               .with_indifferent_access.dig(:employer)) || ""
        end

        def dob_year
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping
                                                                     .with_indifferent_access.dig(:dob_year)) || ""
        end

        def dob_month
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping
                                               .with_indifferent_access.dig(:dob_month)) || ""
        end

        def dob_day
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping
                                               .with_indifferent_access.dig(:dob_day)) || ""
        end

        def date_of_birth
          dob_month&.length > 0 ? "#{dob_month}/#{dob_day}/#{dob_year}" : ""
        end

        def preview_template_service
          NfgCsvImporter::PreviewTemplateService.new(import: view.import)
        end
      end
    end
  end
end
