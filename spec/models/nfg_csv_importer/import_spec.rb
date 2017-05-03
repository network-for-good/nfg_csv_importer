require 'rails_helper'

describe NfgCsvImporter::Import do
  it { should validate_presence_of(:imported_by_id) }
  it { should validate_presence_of(:imported_for_id) }
  it { should validate_presence_of(:import_type)}
  it { should belong_to(:imported_for) }
  it { should belong_to(:imported_by) }
  it { should delegate_method(:description).to(:service)}
  it { should delegate_method(:required_columns).to(:service)}
  it { should delegate_method(:optional_columns).to(:service)}
  it { should delegate_method(:column_descriptions).to(:service)}
  it { should delegate_method(:transaction_id).to(:service)}
  it { should delegate_method(:header).to(:service)}
  it { should delegate_method(:missing_required_columns).to(:service)}
  it { should delegate_method(:import_class_name).to(:service)}
  it { should delegate_method(:headers_valid?).to(:service)}
  it { should delegate_method(:valid_file_extension?).to(:service)}
  it { should delegate_method(:import_model).to(:service)}
  it { should delegate_method(:unknown_columns).to(:service)}
  it { should delegate_method(:all_valid_columns).to(:service)}
  it { should delegate_method(:field_aliases).to(:service)}
  it { should delegate_method(:first_x_rows).to(:service)}
  it { should delegate_method(:invalid_column_rules).to(:service)}
  it { should delegate_method(:can_be_viewed_by).to(:service)}
  it { should delegate_method(:can_be_deleted_by?).to(:service)}

  context "when file is nil" do
    let(:file) { nil }

    it { should validate_presence_of(:import_file) }
  end

  let(:entity) { create(:entity) }
  let(:import_type) { "users" }
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
      let(:file) { '/icon.jpg'}

      it { expect(subject).not_to be }

      it "should add errors to base" do
        subject
        expect(import.errors.messages[:base]).to eq(["Import File can't be blank, Please Upload a File"])
      end
    end

    context "when the file contains an empty header" do
      let(:header_data) { ["first_name", "email", "", "last_name"] }
      it { should_not be }
      it " should add an error to base" do
        subject
        expect(import.errors.messages[:base]).to eq(["At least one empty column header was detected. Please ensure that all column headers contain a value." ])
      end
    end

    context 'when the file contains duplicate headers' do
      let(:header_data) { ["first_name", "email", "first_name", "email", "last_name"] }

      it { expect(subject).not_to be }

      it "should add errors to base" do
        subject
        expect(import.errors.messages[:base]).to eq(["The column headers contain duplicate values. Either modify the headers or delete a duplicate column. The duplicates are: 'first_name' on columns A & C; 'email' on columns B & D"])
      end
    end

    context "when there's an error reading the file" do
      before do
        import.stubs(:duplicated_headers).raises(StandardError)
      end

      it "should add errors to base" do
        subject
        expect(import.errors.messages[:base]).to eq(["We weren't able to parse your spreadsheet.  Please ensure the first sheet contains your headers and import data and retry.  Contact us if you continue to have problems and we'll help troubleshoot."])
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
    let(:errors_csv) { "email,first_name,last_name,Errors\npavan@gmail.com,Arnold,Gilbert,Email is invalid\n" }
    subject { import.set_upload_error_file(errors_csv) }

    it "should uploaded file and store path in error_file attribute" do
      expect { subject }.to change { import.error_file.url }.from(nil).to(String)
    end

    it "should have csv extension" do
      subject
      expect(import.error_file.file.extension).to eq "csv"
    end

  end

  describe "#mapped_fields" do
    before do
      import.fields_mapping = { "first_name" => "first_name", "email" => nil, "last_name" => "ignore_column" }
    end

    context "when no arguments" do
      subject { import.mapped_fields }

      it "should be an array of MappedField objects" do
        expect(subject.first).to be_a(NfgCsvImporter::MappedField)
      end

      it "should have a MappedField for each of the fields_mapping elements" do
        expect(subject.length).to eq(import.fields_mapping.length)
      end
    end

    context "when the argument matches a header in the fields mapping hash" do
      subject { import.mapped_fields("email") }

      it "should return the mapped field for that header" do
        expect(subject).to be_a(NfgCsvImporter::MappedField)
        expect(subject.name).to eq("email")
        expect(subject.mapped_to).to eq(nil)
      end
    end

    context "when the argument does not match a header in the fields mapping hash" do
      subject { import.mapped_fields("bar") }

      it "should return the mapped field for that header" do
        expect(subject).not_to be
      end
    end

  end

  describe "#column_stats" do
    before do
      import.stubs(:fields_mapping).returns({
        "field1" => nil,
        "field2" => "field2",
        "field3" => NfgCsvImporter::Import.ignore_column_value,
        "field4" => "field4"
      })
    end

    subject { import.column_stats }

    it "should return a count of all of the columns" do
      expect(subject[:column_count]).to eq(4)
    end

    it "should return the number of unmapped columns" do
      expect(subject[:unmapped_column_count]).to eq(1)
    end

    it "should return the number of mapped columns" do
      expect(subject[:mapped_column_count]).to eq(2)
    end

    it "should return the number of ignored columns" do
      expect(subject[:ignored_column_count]).to eq(1)
    end
  end

  describe "duplicated_field_mappings" do
    subject { import.duplicated_field_mappings }
    context 'when no field mappings contain two of the same fields' do
      before do
        import.stubs(:fields_mapping).returns({ "First Name" => "first_name"})
      end

      it "should be an empty hash" do
        expect(subject).to eq({})
      end
    end

    context "when the fields mapping contains duplicated fields" do
      before do
        import.stubs(:fields_mapping).returns({ "First Name" => "first_name", "Donor Email" => "email", "Donor First Name" => "first_name"})
      end
      it "should return a hash where the keys are the duplicate fields names and the values are an array header columns mapped to that field" do
        expect(subject).to eq({ "first_name" => ["First Name", "Donor First Name"]})
      end
    end

    context "when the fields mapping contains duplicated fields but they are ignore_columns" do
      before do
        import.stubs(:fields_mapping).returns({ "First Name" => NfgCsvImporter::Import.ignore_column_value, "Donor Email" => "email", "Donor First Name" => NfgCsvImporter::Import.ignore_column_value})
      end
      it "should not include the ignore column dupes in the list" do
        expect(subject).to eq({})
      end
    end

    context "when the fields mapping contains duplicated fields but they are blank values" do
      before do
        import.stubs(:fields_mapping).returns({ "First Name" => nil, "Donor Email" => "email", "Donor First Name" => nil})
      end
      it "should not include the ignore column dupes in the list" do
        expect(subject).to eq({})
      end
    end
  end

  describe "#header_errors" do
    before do
      import.stubs(:invalid_column_rules).returns(invalid_column_rules)
    end

    subject { import.header_errors }

    context 'when invalid_column_rules are empty' do
      let(:invalid_column_rules) { [] }

      it "should be empty" do
        expect(subject).to be_empty
      end
    end

    context 'when invalid_column_rules are not empty' do
      let(:invalid_column_rules) { [mock(message: "bar")] }

      it "should not be empty" do
        expect(subject).to be_present
      end

      it "should include the message returned by the rule validator" do
        expect(subject).to eq(["bar"])
      end
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

  describe "#ready_to_import?" do
    before do
      import.stubs(:headers_valid?).returns(headers_valid)
      import.stubs(:duplicated_field_mappings).returns(duplicated_field_mappings)
      import.stubs(:unmapped_columns).returns(unmapped_columns)
    end
    let(:headers_valid) { true }
    let(:duplicated_field_mappings) { {} }
    let(:unmapped_columns) { [] }

    subject { import.ready_to_import? }

    context "when all fields are mapped or ignored" do
      context "and all header validations (field requirements) are met" do
        context 'and there are no duplicate fields' do
          it "should be true" do
            expect(subject).to be
          end
        end

        context 'and there are duplicate fields' do
          let(:duplicated_field_mappings) { { "field1" => [3,6]} }

          it "should return false" do
            expect(subject).not_to be
          end
        end
      end

      context "and all headers validations are not met" do
        let(:headers_valid) { false }

        it "should be false" do
          expect(subject).not_to be
        end
      end
    end

    context "when all fields are not mapped or ignored" do
      let(:unmapped_columns) { [stub(unmapped: true)] }

      it "should be false" do
        expect(subject).not_to be
      end
    end
  end

  describe "#time_remaining_message" do
    let(:import) { FactoryGirl.build(:import,
                                      imported_for: entity,
                                      import_type: import_type,
                                      imported_by: admin,
                                      import_file: file,
                                      error_file: error_file,
                                      number_of_records: number_of_records,
                                      records_processed: records_processed,
                                      processing_started_at: processing_started_at
                                      ) }
    let(:number_of_records) { nil }
    let(:records_processed) { nil }
    let(:processing_started_at) { nil }

    subject { import.time_remaining_message }
    context 'when the number_of_records is nil' do
      it "should return 'Unknown'" do
        expect(subject).to eq("Unknown")
      end
    end

    context 'when the number_of_records is not nil' do
      let(:number_of_records) { 5000 }

      context 'and the records_processed is nil' do
        it "should return 'Unknown'" do
          expect(subject).to eq("Unknown")
        end
      end

      context "and the records_processed is not nil" do
        let(:records_processed) { 500 }

        context "and the processing_started_at is nil" do
          it "should return 'Unknown'" do
            expect(subject).to eq("Unknown")
          end
        end

        context "and the processing_started_at is 5 minutes ago nil" do
          let(:processing_started_at) { 5.minutes.ago }
          it "should return a value calculated from the start time, total number of records, and number processed" do
            expect(subject).to eq("45 minutes")
          end
        end

        context 'and the processing_started_at is 1 hour ago' do
          let(:processing_started_at) { (1.hour + 15.minutes).ago }

          it "should return a value calculated from the start time, total number of records, and number processed" do
            expect(subject).to eq("11 hours and 15 minutes")
          end
        end
      end

      context "and the records processed equals the number_of_records" do
        let(:records_processed) { 5000 }

        it "should be 0 minutes" do
          expect(subject).to eq("0 minutes")
        end
      end
    end
  end

  describe '#can_be_deleted?' do
    subject { import.can_be_deleted?(admin) }

    context 'when import status is uploaded' do
      before { import.uploaded! }

      it 'returns true' do
        expect(subject).to eq true
      end
    end

    context 'when import status is complete' do
      before do
        import.complete!
        import.stubs(:can_be_deleted_by?).with(admin).returns(can_be_deleted_by_admin)
      end

      context 'when current_user can delete' do
        let(:can_be_deleted_by_admin) { true }

        it 'returns true' do
          expect(subject).to eq true
        end
      end

      context 'when current_user cannot delete' do
        let(:can_be_deleted_by_admin) { false }

        it 'returns false' do
          expect(subject).to eq false
        end
      end
    end
  end
end
