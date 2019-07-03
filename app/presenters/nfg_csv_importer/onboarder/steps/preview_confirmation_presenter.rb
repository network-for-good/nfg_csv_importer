module NfgCsvImporter
  # This needs to inherit from GemPresenter when Imports are real.
  #
  # I anticipate we'll write an ImportResultsPresenter
  # and the preview will inherit or overwrite the output methods for the actual output page. They are the same layout with different info coming in.
  module Onboarder
    module Steps
      class PreviewConfirmationPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter
        attr_accessor :preview_records, :macro_stats

        def humanized_card_header_icon(humanize)
          return 'user' if humanize == 'user'
          return 'dollar' if humanize == 'donation'
        end

        def humanized_card_heading(humanize)
          return name if humanize == 'user'
          return amount if humanize == 'donation'
        rescue StandardError => e
          Rails.logger.error("Failed to retrieve humanized card heading.  Exception: #{e.message}")
        end

        def humanized_card_heading_caption(humanize)
          return [phone, email] if humanize == 'user'
          return [campaign, donated_at] if humanize == 'donation'
        end

        # Anticipating an array of arrays that we loop through.
        # The keyword might then be used to sync up an icon for this data (e.g.: user address = 'house')
        def humanized_card_body(humanize)
          return [{ address: [address,address_2, "#{city}, #{state} #{zip}", country] }] if humanize == 'user'
          return [{ transaction_id: [transaction_id]},{ note: [note]}] if humanize == 'donation'
        end

        def humanized_card_body_icon(keyword)
          case keyword.to_s
          when 'address'
            address.present? ? 'home' : ""
          when 'transaction_id'
            transaction_id.present? ? 'search' : ""
          when 'note'
            note.present? ? 'file-o' : ""
          else
            'circle inverse'
          end
        end

        def chart_thickness
          'C' # corresponds to the appearance of FF Chartwell pie charts.
        end

        def macro_summary_heading_icon(humanize)
          return 'user' if humanize == 'user'
          return 'dollar' if humanize == 'donation'
        end

        def macro_summary_heading(humanize)
          return "Total Est. Contacts" if humanize == 'user'
          return "Total Est. Donations" if humanize == 'donation'
        end

        def macro_summary_heading_value(humanize)
            if humanize == 'user'
              return preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_TOTAL_CONTACTS_KEY) || ""
            end

            if humanize == 'donation'
              return preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_TOTAL_SUM_KEY) || ""
            end
        end

        def macro_summary_charts(humanize)
          if humanize == 'user'
            total_count = preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_TOTAL_CONTACTS_KEY) || ""
            unique_emails = preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_UNIQUE_EMAILS_KEY) || ""
            unique_addresses = preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_UNIQUE_ADDRESSES_KEY) || ""
            return [{ title: "With Emails", total: unique_emails, percentage: percentage(unique_emails, total_count)  },
                    { title: "With Addresses", total: unique_addresses, percentage: percentage(unique_addresses, total_count) }]
          end
          if humanize == 'donation'
            total_sum = preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_TOTAL_SUM_KEY)

            non_zero_amount_donations =  preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_NON_ZERO_AMOUNT_DONATIONS_KEY) || ""
            zero_amount_donations =  preview_statistics&.dig(NfgCsvImporter::Import::STATISTICS_ZERO_AMOUNT_DONATIONS_KEY) || ""
            return [{ title: "Regular Donations", total: non_zero_amount_donations, percentage: percentage(non_zero_amount_donations, total_sum)  },
                    { title: "In-kind Donations", total: zero_amount_donations, percentage: percentage(zero_amount_donations,total_sum) }]
          end
        end

        private

        def percentage(subset,total)
          if total.to_i == 0
            0
          else
            sprintf "%.2f", ((subset.to_f/total.to_f) * 100.0)
          end
        end

        def preview_statistics
          return @macro_stats unless @macro_stats.nil?

          import_statistics = view.import.statistics
          begin
            @macro_stats ||=  import_statistics.nil? ? {} : JSON.parse(import_statistics)
          rescue StandardError => e
            Rails.logger.error("Failed to parse statistics for import: #{e.message}")
            {}
          end
        end

        def subset_of_records_for_preview
          @preview_records ||= preview_template_service.rows_to_render&.first || {}
        end

        def name
          first_name = subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:first_name))
          last_name = subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:last_name))
          first_name.present? || last_name.present? ? "#{first_name} #{last_name}" : ""
        end

        def amount
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:amount)) || ""
        end

        def email
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:email)) || ""
        end

        def phone
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:phone)) || ""
        end

        def address
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:address)) || ""
        end

        def address_2
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:address_2)) || ""
        end

        def city
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:city)) || ""
        end

        def state
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:state)) || ""
        end

        def zip
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:zip_code)) || ""
        end

        def country
          'USA'
        end

        def note
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:note)) || ""
        end

        def transaction_id
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:transaction_id)) || ""
        end

        def donated_at
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:donated_at)) || ""
        end

        def campaign
          subset_of_records_for_preview&.dig(preview_template_service.stats_keys.with_indifferent_access.dig(:campaign)) || ""
        end

        def preview_template_service
          NfgCsvImporter::PreviewTemplateService.new(import: view.import)
        end
      end
    end
  end
end
