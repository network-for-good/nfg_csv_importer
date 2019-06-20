module NfgCsvImporter
  # Ex: NfgCsvImporter::OnboarderPresenter.new(onboarding_session)
  module Onboarder
    class OnboarderPresenter < NfgCsvImporter::GemPresenter

      # Build instead of initialize the OnboarderPresenter.
      # This will initialize the appropriate presenter for that step.
      # All onboarder presenters inherit this presenter.
      # All steps have a presenter (or, at minimum, defined).
      #
      # Example usage on a view:
      # NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, self)
      def self.build(model, view =  NfgCsvImporter::Onboarding::ImportDataController.new.view_context, options = {})
        # raise onboarding_session.inspect
        "NfgCsvImporter::Onboarder::Steps::#{model.current_step.camelize}Presenter".constantize.new(model, view, options)
      rescue
        "No presenter was found for the current step when calling NfgCsvImporter::Onboarder::OnboarderPresenter.build(...): #{model.current_step}.\n\nPlease create the following presenter: NfgCsvImporter::Onboarder::Steps::#{model.current_step.camelize}Presenter\n\n It should also inherit NfgCsvImporter::Onboarder::OnboarderPresenter"

      end

      def onboarder_title
        I18n.t("nfg_csv_importer.onboarding.title_bar.caption", name: (file_origination_type_name.try(:titleize) || ''))
      end

      # Pull this from the onboarding sessions' :step_data to
      # get the authoritative answer.
      def file_origination_type_name
        return '' unless step_data['import_data'].present?

        step_data['import_data'][:file_origination_type_selection]['file_origination_type']
      end

      def file_origination_type
        file_origination_types.select { |t| t.type_sym == file_origination_type_name.to_sym }.first
      end

      def file_origination_types
        NfgCsvImporter::FileOriginationTypes::Manager.new(NfgCsvImporter.configuration).types
      end

      # Detects whether you're currently on the first step in the session
      # or, literally on the first step via clicking the back button
      #
      # Used for supporting whether or not to show things on the
      # first step (e.g.: the steps nav)
      def on_first_step?
        h.first_step
      end

      def first_step
        all_steps.first
      end

      def last_step
        all_steps.last
      end

      # returns an array of symbols: [:step1, :step2, :step3]
      def all_steps
        @all_steps ||= h.controller.wizard_steps
      end
    end
  end
end