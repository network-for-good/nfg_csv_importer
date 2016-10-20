require "rails_helper"

shared_examples_for "an import notification with an errors file link" do
  it "shows the error link" do
    expect(subject.body).to match("Link to error file")
    expect(subject.body).to match(%Q{href="http://example.com:3000/nfg_csv_importer/1"})
  end
end

describe NfgCsvImporter::ImportMailer, type: :feature do

  let(:import) { FactoryGirl.create(:import, import_file: file,
    number_of_records: 100, number_of_records_with_errors: number_of_records_with_errors,
    imported_for: entity, imported_by: admin) }
  let(:admin) {  FactoryGirl.create(:user) }
  let(:entity) { create(:entity) }
  let(:number_of_records_with_errors) { 0 }
  let(:file) { File.open("spec/fixtures/subscribers.csv")}
  let(:translation_scope) { [:import_mailer, :send_import_result] }

  describe "#send_import_result" do
    subject { NfgCsvImporter::ImportMailer.send_import_result(import).deliver }

    it { expect(subject.subject).to eq("Your #{import.import_type} import has completed!") }

    it { expect(Rails.configuration.default_from_address).to match(subject.from.first) }

    it { expect(subject.to).to eq([admin.email])}

    it { expect(subject.body).to match("you imported a #{import.import_type} file") }

    describe "when the import have errors" do
      context "With multiple errors" do
        let(:number_of_records_with_errors) { 20 }
        it_behaves_like "an import notification with an errors file link"
      end

      context "with only one error" do
        let(:number_of_records_with_errors) { 1 }
        it_behaves_like "an import notification with an errors file link"
      end
    end

    describe "when the import don't have any have errors" do
      it "should not have any error link" do
        expect(subject.body).not_to match("Link to error file")
      end
    end
  end
end

