require "rails_helper"

describe NfgCsvImporter::ImportPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:import) { FactoryGirl.create(:import, *import_traits) }
  let(:import_traits) { [] }
  let(:import_presenter) { NfgCsvImporter::ImportPresenter.new(import, h) }

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
