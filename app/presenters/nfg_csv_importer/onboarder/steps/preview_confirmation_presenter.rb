module NfgCsvImporter
  # This needs to inherit from GemPresenter when Imports are real.
  #
  # I anticipate we'll write an ImportResultsPresenter
  # and the preview will inherit or overwrite the output methods for the actual output page. They are the same layout with different info coming in.
  module Onboarder
    module Steps
      class PreviewConfirmationPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter
        require 'nfg_csv_importer/utilities/arithmetic'

        attr_accessor :preview_records, :macro_stats, :user_presenter, :donation_presenter, :user_supplement_presenter

        SUBCLASS_PRESENTER_METHODS = %w[
                                humanized_card_header_icon humanized_card_heading humanized_card_heading_caption
                                humanized_card_body humanized_card_body_icon macro_summary_heading_icon
                                macro_summary_heading_value macro_summary_heading macro_summary_charts
                                humanized_card_body_icon
        ].freeze


        SUBCLASS_PRESENTER_METHODS.each do |name|
          define_method(name) do |humanize, arg = nil|
            send("#{humanize}_presenter").send(name.to_s, arg)
          end
        end

        def humanized_card_body_symbol(keyword, present)
          case keyword.to_s
          when 'address'
            present ? 'home' : ""
          when 'transaction_id'
            present ? 'search' : ""
          when 'note'
            present ? 'file-o' : ""
          else
            'circle inverse'
          end
        end

        def chart_thickness
          'C' # corresponds to the appearance of FF Chartwell pie charts.
        end

        protected

        def subset_of_records_for_preview
          @preview_records ||= preview_template_service.rows_to_render&.first || {}
        end

        private

        def user_presenter
          @user_presenter ||= NfgCsvImporter::Onboarder::Steps::UserPresenter.new(model, view, options)
        end

        def user_supplement_presenter
          @user_supplement_presenter ||= NfgCsvImporter::Onboarder::Steps::UserSupplementPresenter.new(model, view, options)
        end

        def donation_presenter
          @donation_presenter ||= NfgCsvImporter::Onboarder::Steps::DonationPresenter.new(model, view, options)
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
      end
    end
  end
end
