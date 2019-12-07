require 'rails_helper'

describe NfgCsvImporter::DestroyImportJob do
  let(:entity) { create(:entity) }
  let(:user) { create(:user, entity: entity) }
  let(:import) { create(:import, imported_by: user, imported_for: entity) }
  let!(:destroy_import_job) { NfgCsvImporter::DestroyImportJob.new }
  let!(:imported_records) { create_list(:imported_record, number_of_imported_records, import: import, imported_for: entity) }

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

  shared_examples_for "processing after the last batch" do
    it "sends the notification email" do
      NfgCsvImporter::ImportMailer.expects(:send_import_result).with(import).returns(mock("mailer", deliver_now: true))
      subject
    end

    it "sets the import's status to deleted" do
      subject
      expect(import.reload.status).to eql("deleted")
    end

    it 'enqueues a queued status email' do
      NfgCsvImporter::ImportMailer.expects(:send_import_result).returns(mock('import_result', deliver_now: nil))
      subject
    end
  end

  describe "For the last batch that is processed" do
    let(:number_of_imported_records) { 2 }
    let(:batch) { imported_records.map(&:id)}

    it_behaves_like "processing after the last batch"

    it_behaves_like "destroying the imported record"

    context 'when there is a record that was created' do
      context 'when there is a record that cannot be destroyed' do
        let!(:non_deletable_user) { create(:user, email: 'some@example.com') }
        let!(:non_deletable_record) { create(:imported_record, importable: non_deletable_user, import: import, imported_for: entity) }
        let(:batch) { imported_records.map(&:id) << non_deletable_record.id }

        before { User.any_instance.stubs(:can_be_destroyed?).returns(false).then.returns(true) }

        it_behaves_like "processing after the last batch"
      end
    end

    context 'when there is a record that was updated' do
      context 'when there is a record that cannot be destroyed' do
        let!(:updated_user) { create(:user, email: 'some@example.com') }
        let!(:updated_record) { create(:imported_record, importable: updated_user, action: 'updated', import: import, imported_for: entity) }
        let(:batch) { imported_records.map(&:id) << updated_record.id }

        it_behaves_like "processing after the last batch"
      end
    end


  end

  describe "For previous batches" do
    let(:number_of_imported_records) { 4 }
    let(:batch) { imported_records[0..1].map(&:id) }

    it "does not send the email" do
      NfgCsvImporter::ImportMailer.expects(:send_import_result).with(import).never
      subject
    end

    it_behaves_like "destroying the imported record"
  end
end
