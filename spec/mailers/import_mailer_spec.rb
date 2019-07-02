require "rails_helper"

shared_examples_for "an import notification with an errors file link" do
  it "shows the error link" do
    expect(subject.body).to match("error_link")
    expect(subject.body).to match(%Q{test.example.com})
    expect(subject.body).to match("nfg_csv_importer/#{import.id}")
  end
end

describe NfgCsvImporter::ImportMailer, type: :mailer do
  let(:import) { FactoryGirl.create(:import, *import_traits) }

  describe "#send_import_result" do
    before { @import = import } # for the view
    let(:import_traits) { [:is_paypal, :is_complete] }
    subject { NfgCsvImporter::ImportMailer.send_import_result(@import).deliver_now }

    it { expect(subject.subject).to eq("Your #{@import.import_type} import is complete!") }

    it { expect(Rails.configuration.default_from_address).to match(subject.from.first) }

    it { expect(subject.to).to eq([import.imported_by.email])}

    describe "when the import have errors" do
      let(:import_traits) { [:is_paypal, :is_complete_with_errors] }
      context "With multiple errors" do
        it_behaves_like "an import notification with an errors file link"
      end
    end

    describe "when the import don't have any have errors" do
      it "should not have any error link" do
        expect(subject.body).not_to match("error_link")
      end
    end

    context 'when the import status is queued' do
      let(:import) { FactoryGirl.create(:import, :is_queued) }
      subject { NfgCsvImporter::ImportMailer.send_import_result(import, NfgCsvImporter::Import::QUEUED_STATUS).deliver_now }

      it { expect(subject.subject).to eq("Your #{import.import_type} import is #{NfgCsvImporter::Import::QUEUED_STATUS}!") }
    end
  end
end

