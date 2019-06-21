module NfgCsvImporter
  module Onboarder
    # Ex: NfgCsvImporter::Onboarder::NavigationBarPresenter.new(onboarding_session)
    class NavigationBarPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter

      # Returns an nfg_ui friendly status for the :step component's status trait
      #
      # Example usage:
      # = ui.nfg :step, onboarder_presenter.step_status(step, all_steps: controller.wizard_steps), step: i, href: wizard_path(step)
      def step_status(step)
        return :active if step.to_sym == active_step.to_sym
        return :visited if try(:completed_steps, h.controller_name).try(:include?, step)
        return :disabled if all_steps.index(step.to_sym) > all_steps.index(active_step.to_sym)
      end

      def step_icon(step)
        step == last_step ? 'check' : nil
      end

      def hide_steps?
        on_first_step?
      end

      def show_step?(step)
        true
      end
    end
  end
end