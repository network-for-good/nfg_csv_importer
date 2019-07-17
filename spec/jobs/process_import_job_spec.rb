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

  it "should update the processing_started_at" do
    expect{ subject }.to change{ import.reload.processing_started_at }
  end

  it "should send the mail to admin with imported result" do
    NfgCsvImporter::ImportService.any_instance.stubs(:import).returns(nil)
    # one is expected for processing, and another is for completed
    NfgCsvImporter::ImportMailer.expects(:send_import_result).with(import).returns(mock("mailer", deliver_now: true))
    NfgCsvImporter::ImportMailer.expects(:send_import_result).with(import).returns(mock("mailer", deliver_now: true))
    subject
  end

  it { expect { subject }.to change { import.reload.status }.from(nil).to("complete") }

  it { expect { subject }.to change { import.reload.processing_finished_at }.from(nil) }


  it "should set status to processing" do
    NfgCsvImporter::Import.stubs(:find).returns(import)
    import.reload.expects(:processing!)
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

  it 'allows you to start at a specific row in the file' do
    expect { process_import_job.perform(import.id, 3) }.to change { User.count }.by(1)
  end
end
