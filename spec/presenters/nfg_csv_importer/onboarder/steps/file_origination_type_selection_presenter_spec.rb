require "rails_helper"

describe NfgCsvImporter::Onboarder::Steps::FileOriginationTypeSelectionPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:onboarding_session) { FactoryGirl.create(:onboarding_session, *traits) }
  let(:traits) { [:"#{current_step}_step"] } # auto-generate the correct onboarding session step
  let(:current_step) { 'file_origination_type_selection' }
  let(:onboarder_presenter) { NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, h) }

  before { h.controller.stubs(:params).returns(id: current_step) }

  it { expect(described_class).to be < NfgCsvImporter::Onboarder::OnboarderPresenter }

  describe '#show_file_origination_type_name?(type_sym = '')' do
    let(:file_origination_types_that_require_names_to_be_visible) { %w[self_import_csv_xls send_to_nfg] }
    subject { onboarder_presenter.show_file_origination_type_name?(type_sym) }

    context 'when the file origination type name is included on the list of names required' do
      let(:type_sym) { :self_import_csv_xls }
      it { is_expected.to be }
    end

    context 'when the file origination type name is *not* included on the list of names required' do
      let(:type_sym) { :paypal }
      it { is_expected.not_to be }
    end
  end
end
