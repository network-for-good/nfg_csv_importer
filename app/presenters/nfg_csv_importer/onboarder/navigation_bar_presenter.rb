module NfgCsvImporter
  module Onboarder
    # Ex: NfgCsvImporter::Onboarder::NavigationBarPresenter.new(onboarding_session)
    class NavigationBarPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter

      # Returns an nfg_ui friendly status for the :step component's status trait
      #
      # Example usage:
      # = ui.nfg :step, onboarder_presenter.step_status(the_step), step: 1, href: wizard_path(the_step)
      def step_status(step)
        return :active if step.to_sym == active_step.to_sym
        return :disabled if h.before_last_visited_point_of_no_return?(step)
        return :visited if try(:completed_steps, h.controller_name).try(:include?, step)
        # in case steps change, if the step or active step can't be found in what
        # is currently the list of steps (based on the file origination type) don't barf
        return :disabled if (all_steps.index(step.to_sym) || 0) > (all_steps.index(active_step.to_sym) || 0)
      end

      def step_icon(step)
        step == last_step ? 'check' : nil
      end

      def show_step?(step)
        true
      end

      def show_nav?
        active_step.to_sym != all_steps.first
      end
    end
  end
end