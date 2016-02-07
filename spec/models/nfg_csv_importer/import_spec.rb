require 'rails_helper'

describe NfgCsvImporter::Import do
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:entity_id) }
  it { should validate_presence_of(:import_type)}
  it { should belong_to(:entity) }
  it { should belong_to(:user) }

  context "when file is nil" do
    let(:file) { nil }

    it { should validate_presence_of(:import_file) }
  end

  let(:entity) { Entity.first }
  let(:import_type) { "subscriber" }
  let(:file_type) { 'csv' }

  let(:file) do
    File.open("spec/fixtures#{file_name}")
  end

  let(:header_data) { ["email" ,"first_name","last_name"] }
  let(:file_name) { "/subscribers.csv" }
  let(:admin) {  FactoryGirl.create(:supervisor_admin, :entity => entity) }
  let(:import) { FactoryGirl.build(:import, entity: entity, import_type: import_type, admin: admin, import_file: file) }

  it { expect(import.save).to be }

  describe "#valid?" do

    before(:each) do
      csv_data = mock
      csv_data.stubs(:row).with(1).returns(header_data)
      ImportService.any_instance.stubs(:open_spreadsheet).returns(csv_data)
    end

    subject { import.valid? }

    it { expect(subject).to be }

    context "validate when there is no file" do
      let(:file) { nil }

      it { expect(subject).not_to be }

      it "should add errors to base" do
        subject
        expect(import.errors.messages[:base]).to eq(["Import File can't be blank, Please Upload a File"])
      end
    end

    context "with invalid file extensions" do
      let(:file_name) { '/icon.jpg'}

      it { expect(subject).not_to be }

      it "should add errors to base" do
        subject
        expect(import.errors.messages[:base]).to eq(["Import File can't be blank, Please Upload a File"])
      end
    end

    context "with invalid headers" do
      let(:header_data) {["first_name","last_name"]}

      it { expect(subject).not_to be }

      it "should add errors to base" do
        subject
        expect(import.errors.messages[:base]).to eq(["Missing following required columns: [\"email\"]"])
      end
    end

    context "when file doesn't contain all required headers" do
      let(:header_data) {["last_name" ,"first_name","last_name"]}

      it { expect(subject).not_to be }

      it "should show error message" do
        subject
        expect(import.errors.messages[:base]).to eq(["Missing following required columns: [\"email\"]"])
      end
    end

    context "when file contain unknown headers" do
      let(:header_data) {["email" ,"first_name","last_name","middle_name"]}

      it { expect(subject).not_to be }

      it "should show error message" do
        subject
        expect(import.errors.messages[:base]).to eq(["The file contains columns that do not have a corresponding value on the #{import.import_class_name}. Please remove the column(s) or change their header name to match an attribute name. The column(s) are: middle_name"])
      end
    end
  end

  describe "#self.perform(import_id)" do
    before(:each) do
      import.save
      NfgCsvImporter::Import.expects(:find).with(import.id).returns(import)
    end

    subject{ NfgCsvImporter::Import.perform(import.id) }

    specify do
      import.expects(:process_import).once
      subject
    end
  end

  describe "#service" do
    subject { import.service }

    context "when service_name is defined" do

      context "and import_type is project" do
        let(:import_type) { "project" }

        it { expect(subject).to be_an_instance_of(ProjectImportService) }
      end

      context "and import_type is assign_donor_unique_identifier" do
        let(:import_type) { "assign_donor_unique_identifier" }

        it { expect(subject).to be_an_instance_of(AssignDonorUniqueIdentifierImportService) }
      end
    end

    context "when service_name is not defined" do
      let(:import_type) { "subscriber" }

      it { expect(subject).to be_an_instance_of(ImportService) }
    end
  end

  describe "#upload_error_file(errors)" do
    let(:errors_csv) { "email\tfirst_name\tlast_name\tErrors\npavan@gmail.com\tArnold\tGilbert\tEmail is invalid\n" }
    subject { import.send( :upload_error_file, errors_csv) }

    it "should uploaded file and store path in error_file attribute" do
      expect { subject }.to change { import.error_file.url }.from(nil).to(String)
    end

    it "should have xls extension" do
      subject
      expect(import.error_file.file.extension).to eq "xls"
    end

  end

  describe "#process_import" do
    subject { import.process_import }

    it "should update the number_of_records_with_errors" do
      expect{ subject }.to change{ import.number_of_records_with_errors }
    end

    it "should update the number_of_records" do
      expect{ subject }.to change{ import.number_of_records }
    end

    it "should send the mail to admin with imported result" do
      ImportService.any_instance.stubs(:import).returns(nil)
      subject
      email = ActionMailer::Base.deliveries.select { |em| em.subject == I18n.t('subject', scope: [:import_mailer, :send_import_result], import_type: import.import_type)  }[0]
      expect(email).to be_present
    end

    it { expect { subject }.to change { import.status }.from(nil).to("complete") }

    it "should set status to processing" do
      import.expects(:processing!)
      subject
    end

    it "should call import on import service" do
      ImportService.any_instance.expects(:import)
      subject
    end

    it "should set import_id for import service" do
      import.id = 1
      ImportService.any_instance.expects(:import_id=).with(1)
      subject
    end


  end

end
