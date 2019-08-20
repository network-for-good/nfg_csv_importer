require "rails_helper"

describe NfgCsvImporter::Onboarder::Steps::FileOriginationTypeSelectionPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:onboarding_session) { FactoryGirl.create(:onboarding_session, *traits) }
  let(:traits) { [:"#{current_step}_step"] } # auto-generate the correct onboarding session step
  let(:current_step) { 'file_origination_type_selection' }
  let(:onboarder_presenter) { NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, h) }

  before { h.controller.stubs(:params).returns(id: current_step) }

  it { expect(described_class).to be < NfgCsvImporter::Onboarder::OnboarderPresenter }
end
