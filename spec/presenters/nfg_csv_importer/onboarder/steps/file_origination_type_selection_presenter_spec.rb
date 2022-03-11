require "rails_helper"

describe NfgCsvImporter::Onboarder::Steps::FileOriginationTypeSelectionPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:onboarding_session) { FactoryBot.create(:onboarding_session, *traits) }
  let(:traits) { [:"#{current_step}_step"] } # auto-generate the correct onboarding session step
  let(:current_step) { 'file_origination_type_selection' }
  let(:onboarder_presenter) { NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, h) }

  before { h.controller.stubs(:params).returns(id: current_step) }

  it { expect(described_class).to be < NfgCsvImporter::Onboarder::OnboarderPresenter }

  describe '#file_origination_type_title' do
    subject { onboarder_presenter.file_origination_type_title(file_origination_type: file_origination_type) }

    context 'when the file_origination_type_title is present' do
      let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::Manager.new(NfgCsvImporter.configuration).type_for('paypal') }

      let(:traits) { [:paypal_file_origination_type] }
      it 'outputs the custom file origination type title' do
        expect(subject).to eq I18n.t("nfg_csv_importer.onboarding.import_data.file_origination_type_selection.file_origination_type_title.paypal")
      end

    end

    context 'when the file_origination_type_title is not present' do
      let(:traits) { [:self_import_csv_xls_file_origination_type] }
      let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::Manager.new(NfgCsvImporter.configuration).type_for('self_import_csv_xls') }
      it 'outputs the fallback default value of the file origination type #name' do
        expect(subject).to eq file_origination_type.name
      end

    end
  end
end
