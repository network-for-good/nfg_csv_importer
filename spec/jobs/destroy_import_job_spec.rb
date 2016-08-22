require 'rails_helper'

describe NfgCsvImporter::DestroyImportJob do
  let(:user) { create(:user) }
  let(:import) { create(:import, imported_by: user) }
  let!(:destroy_import_job) { NfgCsvImporter::DestroyImportJob.new }
  let!(:imported_records) { create_list(:imported_record, number_of_imported_records, import: import) }

  subject { destroy_import_job.perform(batch, import.id) }

  before { NfgCsvImporter::ImportedRecord.stubs(:batch_size).returns(2) }

  shared_examples_for "destroying the imported record" do
    it "deletes the record" do
      imported_records.map(&:importable).each do |importable|
        importable.expects(:destroy).at_most(batch.size)
      end
      subject
    end
  end

  describe "For the last batch that is processed" do
    let(:number_of_imported_records) { 2 }
    let(:batch) { imported_records.map(&:id)}

    it "sends the notification email" do
      NfgCsvImporter::ImportMailer.expects(:send_destroy_result).with(import).returns(mock("mailer", deliver: true))
      subject
    end

    it "sets the import's status to deleted" do
      subject
      expect(import.reload.status).to eql("deleted")
    end

    it_behaves_like "destroying the imported record"
  end

  describe "For previous batches" do
    let(:number_of_imported_records) { 4 }
    let(:batch) { imported_records[0..1].map(&:id) }

    it "does not send the email" do
      NfgCsvImporter::ImportMailer.expects(:send_destroy_result).with(import).never
      subject
    end

    it "sets the import's status to deleting" do
      subject
      expect(import.reload.status).to eql("deleting")
    end

    it_behaves_like "destroying the imported record"
  end
end
