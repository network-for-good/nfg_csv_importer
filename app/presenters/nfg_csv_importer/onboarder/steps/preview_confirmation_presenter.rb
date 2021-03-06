module NfgCsvImporter
  module Onboarder
    module Steps
      class PreviewConfirmationPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter

        # Generate a Chartwell piechart that outputs HTML that looks like this:
        # (Note: chartwell.js assets are stored in nfg_ui)
        #
        # .chartwell.pies
        #   %span.text-primary 75
        #   %span.text-light 25
        #   %span.text-white C
        def preview_pie_chart(amount:, total:, theme: :primary)
          h.content_tag(:div, class: 'chartwell pies mr-2', style: 'font-size: 76px; line-height: 1;') do

            # The pie chart for the actual amount of data (primary color)
            h.content_tag(:span, calculate_percentage(amount: amount, total: total), class: "text-#{theme}") +

            # The second half of the pie chart, the remainder (gray)
            h.content_tag(:span, calculate_remainder(amount: amount, total: total), class: 'text-light') +

            # The style of the chart thickness (calculated by alpha character via Chartwell.js)
            h.content_tag(:span, 'C', class: 'text-white')
          end
        end

        # Return the requested information or supply a
        # "Not Available" text byte with a tooltip.
        def preview_card_data(data:, heading: false, field_name: 'this information')
          body = data.present? ? data : 'Not available'
          typeface_component = heading ? :heading : :body

          if data.present?
            h.ui.nfg(:typeface, typeface_component => body, class: 'mb-0')
          else
            h.ui.nfg(:typeface, :muted, typeface_component => h.ui.nfg(:icon, 'info-circle', :primary, :right, text: 'Not available', tooltip: I18n.t('nfg_csv_importer.onboarding.import_data.preview_confirmation.tooltips.preview_card_data_not_present', field_name: field_name)), class: 'mb-0')
          end
        end

        # donated_at may have been converted to a datetime
        # by Roo, so we check that first before trying to
        # parse
        def donation_date(donated_at)
          donation_date = donated_at.is_a?(String) ? (Time.zone.parse(donated_at) rescue nil) : donated_at
          donation_date.try(:to_s, :month_day_yyyy) || donated_at
        end

        private

        def calculate_percentage(amount:, total:)
          ((amount.to_f / total.to_f) * 100).ceil
        end

        # Chartwell piecharts are out of a total of 100
        # So calculate the un-used percentage to return the second value
        # for Chartwell.
        #
        # Example: if the amount is 75% (75.0). This will return 25.0
        def calculate_remainder(amount:, total:)
          100 - calculate_percentage(amount: amount, total: total)
        end
      end
    end
  end
end
