module NfgCsvImporter
  module Mailers
    # Pass the @import into the model arg for ImportMailerPresenter
    class ImportMailerPresenter < NfgCsvImporter::GemPresenter
      def active_milestone?(milestone:)
        milestones.index(milestone) == milestones.index(status.to_sym)
      end

      def show_successful_import_illustration?
        status.to_sym == NfgCsvImporter::Import::COMPLETED_STATUS && !errors?
      end

      # for now, steps are shown except when
      # on the last step without errors.
      # This may change, so this is kept out as its own method
      # instead of the opposing `else` for `show_successful_import_illustration?`
      def show_steps?
        !show_successful_import_illustration?
      end

      def status_result_alert_message
        I18n.t("send_import_result_mailer.alert.#{status}", scope: locales_scope)
      end

      def show_visit_show_page_button?
        status.to_sym == NfgCsvImporter::Import::COMPLETED_STATUS
      end

      def milestone_image(milestone:)
        # Return a pre-made circle image with a number in it.
        if upcoming_milestone?(milestone: milestone)
          h.image_path("nfg_csv_importer/email/disabled-circle-#{milestones.index(milestone) + 1}.png") if upcoming_milestone?(milestone: milestone)
        else
          # Return the success check mark
          h.image_path('nfg_ui/email/icons/fa-check-circle-success.png')
        end
      end

      def milestone_typeface(milestone:)
        tag = active_milestone?(milestone: milestone) ? :b : :span
        css_class = upcoming_milestone?(milestone: milestone) ? 'text-muted' : nil
        body = I18n.t("send_import_result_mailer.milestones.#{milestone}", scope: locales_scope)

        h.content_tag(tag, body, class: css_class)
      end

      def past_milestone?(milestone:)
        milestones.index(milestone) < milestones.index(status.to_sym)
      end

      def show_errors?
        errors?
      end

      def upcoming_milestone?(milestone:)
        milestones.index(milestone) > milestones.index(status.to_sym)
      end

      private

      def errors?
        error_file.present? && number_of_records_with_errors.to_i >= 1
      end

      def locales_scope
        [:mailers, :nfg_csv_importer]
      end

      # In order:
      # 1. Placed in the queue (QUEUED_STATUS / :queued)
      # 2. Processing begins (PROCESSING_STATUS / :processing)
      # 3. Completed (COMPLETED_STATUS / :complete)
      def milestones
        [
          NfgCsvImporter::Import::QUEUED_STATUS,
          NfgCsvImporter::Import::PROCESSING_STATUS,
          NfgCsvImporter::Import::COMPLETED_STATUS
        ]
      end


    end
  end
end