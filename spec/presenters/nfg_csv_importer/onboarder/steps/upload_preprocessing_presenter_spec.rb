require "rails_helper"

describe NfgCsvImporter::Onboarder::Steps::UploadPreprocessingPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:onboarding_session) { FactoryBot.create(:onboarding_session, *traits, current_step: current_step) }
  let(:traits) { [] }
  let(:current_step) { 'upload_preprocessing' }
  let(:onboarder_presenter) { NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, h) }
  let(:scope) { [:nfg_csv_importer, :onboarding, :import_data, :upload_preprocessing] }

  before { h.controller.stubs(:params).returns(id: current_step) }

  it { expect(described_class).to be < NfgCsvImporter::Onboarder::OnboarderPresenter }

  describe '#header_page_text' do
    subject { onboarder_presenter.header_page_text }
    context 'when the header text is for an existing file_origination_type' do
      let(:traits) { [:paypal_file_origination_type] }
      it 'renders the paypal pre-formatted header text using the file origination type type_sym attribute' do
        expect(subject).to eq I18n.t(".header.file_origination_type.page.paypal", scope: scope)
      end
    end

    context 'when the file origination type does not have a custom header text' do
      let(:traits) { [:self_import_csv_xls_file_origination_type] }

      it 'renders the default language' do
        expect(subject).to eq I18n.t('.header.page',
                                  scope: scope,
                                  file_origination_type: "Your own spreadsheet",
                                  description_of_files: "they come in a 'package' and look like this: some_filename.csv")
      end
    end
  end

  describe '#header_message_text' do
    subject { onboarder_presenter.header_message_text }
    context 'when the file origination type does not have a custom header message' do
      let(:traits) { [:paypal_file_origination_type] }
      it 'renders the correct header message text usingn the default fallback' do
        expect(subject).to eq I18n.t('.header.message', file_origination_type: 'PayPal', scope: scope)
      end
    end

    context 'when the file origination type does not have a custom header text' do
      let(:traits) { [:send_to_nfg_file_origination_type] }

      it 'renders the default language' do
        expect(subject).to eq I18n.t('.header.file_origination_type.message.send_to_nfg', scope: scope)
      end
    end
  end
end