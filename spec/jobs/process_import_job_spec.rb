require 'rails_helper'

describe NfgCsvImporter::ProcessImportJob do
  let!(:user) { create(:user) }
  let(:import) { create(:import, imported_by: user) }
  let(:process_import_job) { NfgCsvImporter::ProcessImportJob.new }

  subject { process_import_job.perform(import.id) }

  it "should update the number_of_records_with_errors" do
    expect{ subject }.to change{ import.reload.number_of_records_with_errors }
  end

  it "show update import record's error_file" do
    expect{ subject }.to change{ import.reload.error_file.url }
  end

  it "should update the number_of_records" do
    expect{ subject }.to change{ import.reload.number_of_records }
  end

  describe "if the job is run again after the import is finished" do
    let(:processing_finished_at) { nil }

    before do
      import.update(
        status: 'processing',
        number_of_records: 4,
        records_processed: 5,
        processing_finished_at: processing_finished_at
      )
      NfgCsvImporter::Import.stubs(:find).returns(import)
    end

    it "does not try to finish processing the import" do
      NfgCsvImporter::ImportService.any_instance.expects(:import).never
      subject
    end

    it "completes the import" do
      import.expects(:complete!).once
      subject
    end
  end

  describe "updating the processing_started_at timestamp" do
    context "When the job is enqueued the first time" do
      it "should update the processing_started_at" do
        expect{ subject }.to change{ import.reload.processing_started_at }
      end
    end

    context "When the job is enqueued subsequent times" do
      before { import.update(records_processed: 3) }
      it "does not update the timestsamp" do
        expect { subject }.not_to change { import.reload.processing_started_at }
      end
    end
  end

  describe "sending the notification email" do
    context "The first time the job is placed on the queue" do
      it "should send the mail to admin with imported result" do
        NfgCsvImporter::ImportService.any_instance.stubs(:import).returns(nil)
        # one is expected for processing, and another is for completed
        NfgCsvImporter::ImportMailer.expects(:send_import_result).with(import).returns(mock("mailer", deliver_later: true))
        NfgCsvImporter::ImportMailer.expects(:send_import_result).with(import).returns(mock("mailer", deliver_later: true))
        subject
      end
    end

    context "When the job is enqueued subsequent times" do
      before { import.update(records_processed: 3) }

      it "does not send the notification email" do
        NfgCsvImporter::ImportMailer.expects(:send_import_result).with(import).returns(mock("mailer", deliver_later: true))
        subject
      end
    end
  end

  it { expect { subject }.to change { import.reload.status }.from(nil).to("complete") }

  it { expect { subject }.to change { import.reload.processing_finished_at }.from(nil) }

  it "should set status to processing" do
    NfgCsvImporter::Import.stubs(:find).returns(import)
    import.stubs(:processing?).returns(false)
    import.reload.expects(:processing!).returns(import.update(status: 'processing'))
    subject
  end

  it 'enqueues an email' do
    # it is expected twice one for processing, and one for complete
    NfgCsvImporter::ImportMailer.expects(:send_import_result).returns(mock('import_result', deliver_later: nil))
    NfgCsvImporter::ImportMailer.expects(:send_import_result).returns(mock('import_result', deliver_later: nil))
    subject
  end

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

  describe "resuming from the last processed row" do
    before { import.update(records_processed: 1) }
    it 'allows you to restart at the next row' do
      expect { process_import_job.perform(import.id) }.to change { User.count }.by(1)
    end
  end
end
