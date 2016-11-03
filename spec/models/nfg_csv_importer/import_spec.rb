require 'rails_helper'

describe NfgCsvImporter::Import do
  it { should validate_presence_of(:imported_by_id) }
  it { should validate_presence_of(:imported_for_id) }
  it { should validate_presence_of(:import_type)}
  it { should belong_to(:imported_for) }
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
  let(:error_file) { nil }
  let(:import) { FactoryGirl.build(:import, imported_for: entity, import_type: import_type, imported_by: admin, import_file: file, error_file: error_file) }

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

    # TODO These validations will be appropriate
    # when we want to know if the import is ready for import
    # and they will use the fields_mapping instead of the list of headers

    # context "with invalid headers" do
    #   let(:header_data) {["first_name","last_name"]}

    #   it { expect(subject).not_to be }

    #   it "should add errors to base" do
    #     subject
    #     expect(import.errors.messages[:base]).to eq(["Missing following required columns: [\"email\"]"])
    #   end
    # end

    # context "when file doesn't contain all required headers" do
    #   let(:header_data) {["last_name" ,"first_name","last_name"]}

    #   it { expect(subject).not_to be }

    #   it "should show error message" do
    #     subject
    #     expect(import.errors.messages[:base]).to eq(["Missing following required columns: [\"email\"]"])
    #   end
    # end

    # context "when file contain unknown headers" do
    #   let(:header_data) {["email" ,"first_name","last_name","middle_name"]}

    #   it { expect(subject).not_to be }

    #   it "should show error message" do
    #     subject
    #     expect(import.errors.messages[:base]).to eq(["The file contains columns that do not have a corresponding value on the #{import.import_class_name}. Please remove the column(s) or change their header name to match an attribute name. The column(s) are: middle_name"])
    #   end
    # end
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

  describe "#mapped_fields" do
    before do
      import.fields_mapping = { "first_name" => "first_name", "email" => nil, "last_name" => "ignore_column" }
    end
    subject { import.mapped_fields }

    it "should be an array of MappedField objects" do
      expect(subject.first).to be_a(NfgCsvImporter::MappedField)
    end

    it "should have a MappedField for each of the fields_mapping elements" do
      expect(subject.length).to eq(import.fields_mapping.length)
    end
  end

  describe "time_zone" do
    subject { import.time_zone }
    context 'when imported_for does not respond to time_zone' do
      it "should return 'Eastern Time (US & Canada)'" do
        expect(subject).to eq('Eastern Time (US & Canada)')
      end
    end

    context "when imported_for responds to time_zone but time_zone is null" do
      before do
        Entity.any_instance.stubs(:time_zone).returns(nil)
      end
      it "should return 'Eastern Time (US & Canada)'" do
        expect(subject).to eq('Eastern Time (US & Canada)')
      end
    end

    context 'when imported_for responds to time_zone and returns a value' do
      before do
        Entity.any_instance.stubs(:time_zone).returns("Indiana (East)")
      end
      it "should return imported_for's time_zone" do
        expect(subject).to eq("Indiana (East)")
      end
    end
  end

  describe "maybe_append_to_existing_errors" do
    let(:errors_csv) { "email\tfirst_name\tlast_name\tErrors\npavan@gmail.com\tArnold\tGilbert\tEmail is invalid\n" }
    let(:subject) { import.maybe_append_to_existing_errors(errors_csv) }

    context 'when error_file is blank' do
      it 'return errors_csv unchanged' do
        expect(subject).to eq errors_csv
      end
    end

    context 'when error_file is present' do
      let(:error_file) { File.open("spec/fixtures/errors.xls") }

      it 'appends to existing errors_csv' do
        csv = CSV.parse(subject, col_sep: "\t")
        expect(csv.size).to eq 3
        expect(subject).to include 'pavan@gmail.com' # new errors
        expect(subject).to include 'ajporterfield@gmail' # existing errors
      end
    end
  end
end
