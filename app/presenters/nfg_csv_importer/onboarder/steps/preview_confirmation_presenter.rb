module NfgCsvImporter
  # This needs to inherit from GemPresenter when Imports are real.
  #
  # I anticipate we'll write an ImportResultsPresenter
  # and the preview will inherit or overwrite the output methods for the actual output page. They are the same layout with different info coming in.
  module Onboarder
    module Steps
      class PreviewConfirmationPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter

        # Generate a Chartwell piechart that outputs HTML that looks like this:
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

        def preview_card_data(data:, heading: false)
          body = data.present? ? data : 'Not available'
          typeface_component = heading ? :heading : :body

          if data.present?
            h.ui.nfg(:typeface, typeface_component => body, class: 'mb-0')
          else
            h.ui.nfg(:typeface, :muted, typeface_component => h.ui.nfg(:icon, 'info-circle', :primary, :right, text: 'Not available'), tooltip: I18n.t('nfg_csv_importer.onboarding.import_data.preview_confirmation.tooltips.preview_card_data_not_present'))
          end
        end

        private

        def calculate_percentage(amount:, total:)
          ((amount.to_f / total.to_f) * 100).ceil
        end

        # Chartwell piecharts are out of a total of 100
        # So calculate the un-used percentage to return the second value
        # for Chartwell.
        #
        # Example: if the amount is 75%. This will return 25.
        def calculate_remainder(amount:, total:)
          100 - calculate_percentage(amount: amount, total: total)
        end
      end
    end
  end
end
