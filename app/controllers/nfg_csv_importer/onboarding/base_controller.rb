class NfgCsvImporter::Onboarding::BaseController < NfgCsvImporter::ApplicationController
  include Wicked::Wizard

  require 'nfg_onboarder/onboarding_controller_helper'
  include NfgOnboarder::OnboardingControllerHelper

  expose(:current_next_step) { next_step }
end
