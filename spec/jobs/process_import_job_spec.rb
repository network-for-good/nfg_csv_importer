require 'rails_helper'

shared_examples_for "processing the import" do
  it { expect { subject }.to change { import.reload.number_of_records_with_errors } }
  it { expect { subject }.to change { import.reload.error_file.url } }
  it { expect { subject }.to change { import.reload.number_of_records } }
  it { expect { subject }.to change { import.reload.status }.from(queued_status).to(completed_status) }
  it { expect { subject }.to change { import.reload.processing_finished_at }.from(nil) }

  it "should call import on import service" do
    NfgCsvImporter::ImportService.any_instance.expects(:import)
    subject
  end

  it "should set import_id for import service" do
    subject
    expect(import.service.import_record).to eql(import)
  end

  it "creates a record for each row" do
    expect { subject }.to change { User.count }.by(2)
  end
end

shared_examples_for "halting any further processing" do
  it "does not try to finish processing the import" do
    NfgCsvImporter::ImportService.any_instance.expects(:import).never
    subject
  end
end

describe NfgCsvImporter::ProcessImportJob do
  let(:queued_status) { NfgCsvImporter::Import::QUEUED_STATUS.to_s }
  let(:completed_status) { NfgCsvImporter::Import::COMPLETED_STATUS.to_s }
  let(:processing_status) { NfgCsvImporter::Import::PROCESSING_STATUS.to_s }
  let(:user) { create(:user) }
  let(:status) { queued_status }
  let(:number_of_records) { nil }
  let(:records_processed) { nil }
  let(:processing_finished_at) { nil }
  let(:import) do
    create(:import,
      imported_by: user,
      status: status,
      number_of_records: number_of_records,
      records_processed: records_processed,
      processing_finished_at: processing_finished_at
    )
  end
  let(:process_import_job) { NfgCsvImporter::ProcessImportJob.new }

  before { NfgCsvImporter::Import.stubs(:find).returns(import) }

  subject { process_import_job.perform(import.id) }

  describe "statuses" do
    context "with a status of queued" do
      let(:status) { queued_status }

      it "changes the status to processing" do
        import.expects(:processing!).once
        subject
      end

      it_behaves_like "processing the import"
    end

    context "with a status of processing" do
      let(:status) { processing_status }
      let(:number_of_records) { 4 }
      let(:records_processed) { 2 }
      let(:processing_finished_at) { nil }

      describe "when records_processed is greater than number_of_records" do
        let(:number_of_records) { 4 }
        let(:records_processed) { 5 }


        it "completes the import" do
          import.expects(:complete!).once
          subject
        end
      end

      it_behaves_like "halting any further processing"
    end

    context "with a status of complete" do
      let(:status) { completed_status }
      it_behaves_like "halting any further processing"
    end
  end

  describe "handling Sidekiq worker restarts" do
    before { $shutdown_pending = true }
    after { $shutdown_pending = nil }

    it "raises Sidekiq::Shutdown and sets the import status back to queued" do
      expect { subject }.to raise_error(Sidekiq::Shutdown)
      expect(import.reload.status).to eql NfgCsvImporter::Import::QUEUED_STATUS.to_s
    end
  end

  describe "updating the processing_started_at timestamp" do
    context "When the job is enqueued the first time" do
      let(:records_processed) { nil }
      it { expect { subject }.to change { import.reload.processing_started_at } }
    end

    context "When the job is enqueued subsequent times" do
      let(:records_processed) { 3 }
      it { expect { subject }.not_to change { import.reload.processing_started_at } }
    end
  end

  describe "sending the notification email" do
    let(:processing_email_subject) { "Your import is processing!" }
    let(:complete_email_subject) { "Your import is complete!" }

    before { ActionMailer::Base.deliveries.clear }

    subject { ActionMailer::Base.deliveries.map(&:subject) }

    context "The first time the job is placed on the queue" do
      let(:records_processed) { nil }

      before { process_import_job.perform(import.id) }

      it { should contain_exactly(processing_email_subject, complete_email_subject) }
    end

    context "When the job is enqueued subsequent times" do
      let(:records_processed) { 3 }
      before { process_import_job.perform(import.id) }
      it { should contain_exactly(complete_email_subject) }
    end
  end

  describe "resuming from the last processed row" do
    let(:records_processed) { 1 }
    it { expect { process_import_job.perform(import.id) }.to change { User.count }.by(1) }
  end
end
