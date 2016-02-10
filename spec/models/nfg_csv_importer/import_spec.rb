require 'rails_helper'

describe NfgCsvImporter::Import do
  it { should validate_presence_of(:imported_by_id) }
  it { should validate_presence_of(:entity_id) }
  it { should validate_presence_of(:import_type)}
  it { should belong_to(:entity) }
  it { should belong_to(:imported_by) }

  context "when file is nil" do
    let(:file) { nil }

    it { should validate_presence_of(:import_file) }
  end

  let(:entity) { create(:entity) }
  let(:import_type) { "user" }
  let(:file_type) { 'csv' }

  let(:file) do
    File.open("spec/fixtures#{file_name}")
  end

  let(:header_data) { ["email" ,"first_name","last_name"] }
  let(:file_name) { "/subscribers.csv" }
  let(:admin) {  create(:user) }
  let(:import) { FactoryGirl.build(:import, entity: entity, import_type: import_type, imported_by: admin, import_file: file) }

  it { expect(import.save).to be }

  describe "#valid?" do

    before(:each) do
      csv_data = mock
      csv_data.stubs(:row).with(1).returns(header_data)
      NfgCsvImporter::ImportService.any_instance.stubs(:open_spreadsheet).returns(csv_data)
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

  describe "#service" do
    subject { import.service }

    context "when service_name is defined" do

      context "and import_type is project" do
        let(:import_type) { "another_importer" }

        it { expect(subject).to be_an_instance_of(AnotherImporterImportService) }
      end
    end

    context "when service_name is not defined" do
      let(:import_type) { "subscriber" }

      it { expect(subject).to be_an_instance_of(NfgCsvImporter::ImportService) }
    end
  end

  describe "#upload_error_file(errors)" do
    let(:errors_csv) { "email\tfirst_name\tlast_name\tErrors\npavan@gmail.com\tArnold\tGilbert\tEmail is invalid\n" }
    subject { import.set_upload_error_file(errors_csv) }

    it "should uploaded file and store path in error_file attribute" do
      expect { subject }.to change { import.error_file.url }.from(nil).to(String)
    end

    it "should have xls extension" do
      subject
      expect(import.error_file.file.extension).to eq "xls"
    end

  end
end
