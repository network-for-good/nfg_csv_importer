require "rails_helper"

describe NfgCsvImporter::ImportPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:import) { FactoryGirl.create(:import, *import_traits) }
  let(:import_traits) { [] }
  let(:import_presenter) { NfgCsvImporter::ImportPresenter.new(import, h) }

  describe '#import_note' do
    let(:onboarding_session) { FactoryGirl.create(:onboarding_session, :send_to_nfg_file_origination_type) }
    let(:test_note) { 'the tested note' }

    before do
      import.stubs(:onboarding_session).returns(onboarding_session)
      onboarding_session.step_data['import_data'] = { upload_preprocessing: { 'note' => test_note } }
    end

    subject { import_presenter.import_note }

    it "yields the saved note stored in the factory" do
      expect(subject).to eq test_note
    end
  end

  describe '#file_origination_type_name' do
    let(:tested_file_origination_type) { nil }
    let(:import) { FactoryGirl.create(:import, file_origination_type: tested_file_origination_type) }

    subject { import_presenter.file_origination_type_name }

    context 'when the file_origination_type is set' do
      let(:tested_file_origination_type) { 'paypal' }
      it 'returns the #name of the file origination type' do
        expect(subject).to eq "PayPal"
      end
    end

    context 'when the file_origination_type is not set' do
      let(:tested_file_origination_type) { nil }

      it 'defaults to the self import csv xls file origination type' do
        expect(subject).to eq "Your own spreadsheet"
      end
    end
  end
end
