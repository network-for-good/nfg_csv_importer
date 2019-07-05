module NfgCsvImporter
  # This needs to inherit from GemPresenter when Imports are real.
  #
  # I anticipate we'll write an ImportResultsPresenter
  # and the preview will inherit or overwrite the output methods for the actual output page. They are the same layout with different info coming in.
  module Onboarder
    module Steps
      class UserPresenter < NfgCsvImporter::Onboarder::Steps::PreviewConfirmationPresenter
        require 'nfg_csv_importer/shareable/preview_presentable'
        include NfgCsvImporter::PreviewPresentable

        attr_accessor :preview_records

        def humanized_card_header_icon
          'user'
        end

        def humanized_card_heading
          name
        rescue StandardError => e
          Rails.logger.error("Failed to retrieve humanized card heading.  Exception: #{e.message}")
        end

        def humanized_card_heading_caption
          [phone, email]
        end

        # Anticipating an array of arrays that we loop through.
        # The keyword might then be used to sync up an icon for this data (e.g.: user address = 'house')
        def humanized_card_body
          [{ address: [address,address_2, "#{city}, #{state} #{zip}", country] }]
        end

        private

        def name
          first_name = subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:first_name))
          last_name = subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:last_name))
          first_name.present? || last_name.present? ? "#{first_name} #{last_name}" : ""
        end

        def email
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:email)) || ""
        end

        def phone
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:phone)) || ""
        end

        def address
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:address)) || ""
        end

        def address_2
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:address_2)) || ""
        end

        def city
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:city)) || ""
        end

        def state
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:state)) || ""
        end

        def zip
          subset_of_records_for_preview&.dig(preview_template_service.nfg_csv_importer_to_host_mapping.with_indifferent_access.dig(:zip_code)) || ""
        end

        def country
          'USA'
        end

        def preview_template_service
          NfgCsvImporter::PreviewTemplateService.new(import: view.import)
        end
      end
    end
  end
end
