require 'rails_helper'
require 'roo'

shared_examples_for "a row that raises an exception" do
  it "doesn't raise an exception" do
    expect { subject.import }.not_to raise_error
  end

  it "doesn't persist the record" do
    subject
    expect { subject.import }.not_to change(class_to_be_imported, :count)
  end

  it "adds an error" do
    subject
    expect(subject.import).to match(I18n.t(:exception_while_saving_row, scope: [:process, :create]))
  end

  it "only increments the errors counter once" do
    NfgCsvImporter::Import.expects(:increment_counter).with(:number_of_records_with_errors, import.id).once
    NfgCsvImporter::Import.expects(:increment_counter).with(:records_processed, import.id).once
    subject.import
  end

end

describe NfgCsvImporter::ImportService do

  let(:entity) { create(:entity) }
  let(:import_type) { "users" }
  let(:class_to_be_imported) { User }
  let(:file_type) { 'csv' }

  let(:file) do
    import.import_file
  end

  let(:row_data) {["pavan@gmail.com","A Gilbert","William"]}
  let(:header_data) {["email" ,"first_name","last_name"]}
  let(:file_name) {"/subscribers.csv"}
  let!(:admin) {  FactoryGirl.create(:user)}
  let(:import_service) { NfgCsvImporter::ImportService.new(imported_for: entity, type: import_type, file: file, imported_by: admin, import_record: import)}
  let(:import) { FactoryGirl.build(:import,
                                    id: 1,
                                    import_file: File.open("spec/fixtures#{file_name}"),
                                    fields_mapping: fields_mapping)}
  let(:fields_mapping) { { "email" => "email", "first_name" => "first_name", "last_name" => "last_name" } }
  let(:column_validator) { NfgCsvImporter::ColumnValidator.new({ type: "any", fields: ["first_name", "last_name"]}) }

  it { should delegate_method(:class_name).to(:import_definition)}
  it { should delegate_method(:required_columns).to(:import_definition)}
  it { should delegate_method(:optional_columns).to(:import_definition)}
  it { should delegate_method(:column_descriptions).to(:import_definition)}
  it { should delegate_method(:description).to(:import_definition)}
  it { should delegate_method(:field_aliases).to(:import_definition)}
  it { should delegate_method(:column_validation_rules).to(:import_definition)}
  it { should delegate_method(:fields_that_allow_multiple_mappings).to(:import_definition)}
  it { should delegate_method(:can_be_viewed_by).to(:import_definition)}

  describe "subscriber" do
    let!(:csv_data) { mock }

    subject { import_service }

    it { expect(subject.type).to be import_type }
    it { expect(subject.imported_for).to be entity }
    it { expect(subject.imported_by).to be admin }

    before(:each) do
      NfgCsvImporter::ImportService.any_instance.stubs(:file).returns(file)
      NfgCsvImporter::Import.stubs(:find).returns(import)
    end

    it "should get proper import definition" do
      expect(subject.import_definition.class_name).to eq "User"
    end

    it "should set the time zone value" do
      subject.import
    end

    describe "subscriber import" do
      before(:each) do
        csv_data.stubs(:row).with(1).returns(header_data)
        csv_data.stubs(:row).with(2).returns(row_data)
        csv_data.stubs(:last_row).returns(2)
        NfgCsvImporter::ImportService.any_instance.stubs(:open_spreadsheet).returns(csv_data)
      end

      it "should persist the record " do
        expect(subject.import).to be_nil
      end

      describe "the imported record" do
        it "should create importedrecord" do
          expect {subject.import }.to change(NfgCsvImporter::ImportedRecord, :count)
        end

        it "sets the importable" do
          subject.import
          expect(NfgCsvImporter::ImportedRecord.last.importable).to eql(User.last)
        end

        context "when importable is blank, invalid, or not persisted" do
          it "leaves importable empty" do
            User.any_instance.stubs(:save).returns(nil)
            subject.import
            expect(subject.errors_list.size).to eq 1
          end
        end
      end

      context "when the header data contains extra spaces and capitalizations" do
        let(:header_data) {["email " ," first_name","Last_Name"]}

        it "should strip and downcase headers and persist records" do
          expect(subject.import).to be_nil
          expect(class_to_be_imported.find_by_email("pavan@gmail.com")).not_to be_nil
        end

      end

      context "when data has extra white spaces" do
        let(:row_data) {[" pavan@gmail.com "," A Gilbert ",""]}

        it "should trim and persist" do
          expect(subject.import).to be_nil
          expect(class_to_be_imported.find_by_email("pavan@gmail.com")).not_to be_nil
        end
      end

      context "when file has invalid records" do
        let(:row_data) {["pavangmail.com","",""]}

        it "should not persist any record" do
          subject
          expect {subject.import }.not_to change(class_to_be_imported, :count)
        end

        it "should fill have error" do
          expect(subject.import).to match("Email is invalid")
        end
      end

      context "when a record raises an exception during the valid check" do
        before { class_to_be_imported.any_instance.stubs(:valid?).raises(StandardError) }
        it_behaves_like "a row that raises an exception"
      end

      context "when a record raises an exception while saving" do
        before do
          class_to_be_imported.any_instance.stubs(:valid?).returns(true)
          class_to_be_imported.any_instance.stubs(:save).raises(StandardError)
        end
        it_behaves_like "a row that raises an exception"
      end

      context "when a record raises an exception when calling validate_object" do
        before do
          class_to_be_imported.any_instance.stubs(:valid?).returns(true)
          class_to_be_imported.any_instance.stubs(:save).returns(false)
          import_service.stubs(:validate_object).raises(StandardError)
        end
        it_behaves_like "a row that raises an exception"
      end
    end

    context "when default values present" do
      before do
        ImportDefinition.any_instance
                .stubs(:users)
                .returns({
                required_columns: %w{email first_name last_name},
                optional_columns: [],
                alias_attributes: [],
                default_values: {"last_name" => default_value },
                class_name: "User"
                })
      end

      context "when the default value is a string" do
        let(:default_value) { "not provided" }

        it "should assign default values for blank fields and not change non-blank values" do
          NfgCsvImporter::ImportService.new(imported_for: entity, type: import_type, file: file, imported_by: admin, import_record: import).import
          expect(class_to_be_imported.find_by_email("pavan@gmail.com").last_name).to eq("not provided")
          expect(class_to_be_imported.find_by_email("bert@smert.com").last_name).to eq("Smert")
        end

      end

      context "when the default value is a lambda" do
        let(:default_value) { lambda { |row| row["email"].try(:split, "@").try(:first) } }

        it "should assign default values for blank fields and not change non-blank values" do
          NfgCsvImporter::ImportService.new(imported_for:entity,type:import_type,file:file,imported_by: admin, import_record: import).import
          expect(class_to_be_imported.find_by_email("pavan@gmail.com").last_name).to eq("pavan")
          expect(class_to_be_imported.find_by_email("bert@smert.com").last_name).to eq("Smert")
        end

      end
    end

    it "should support csv import" do
      expect(subject.send(:open_spreadsheet)).to be_an_instance_of(Roo::CSV)
    end

    context "Invalid file content" do
      let(:file_name) { '/subscribers.xlsx'}
      let(:file_type) { 'xlsx' }

      it "should append error message" do

        expect(subject.import).to match("Email is invalid")
      end
    end

    describe "#open_spreadsheet" do
      context "csv file" do
        it "should return Roo::Csv" do
          expect(subject.send(:open_spreadsheet)).to be_an_instance_of(Roo::CSV)
        end
      end

      context "xls file" do
        let(:file_name) { '/subscribers.xls'}
        let(:file_type) { 'xls' }

        it "should return Roo::Excel" do
          expect(subject.send(:open_spreadsheet)).to be_an_instance_of(Roo::Excel)
        end
      end

      context "xlsx file" do
        let(:file_name) { '/subscribers.xlsx'}
        let(:file_type) { 'xlsx' }

        it "should return Roo::Excelx" do
          expect(subject.send(:open_spreadsheet)).to be_an_instance_of(Roo::Excelx)
        end
      end
    end
  end

  describe "#assign_defaults" do
    let(:obj) { NfgCsvImporter::ImportService.new(imported_for:entity,type:import_type) }

    context "when model is subscriber" do
      let(:attributes) { { email: "first@mail.com", first_name: 'fname', last_name: 'lname' } }


      before do
        ImportDefinition.any_instance.stubs(:user)
          .returns({
          default_values: { },
          alias_attributes: [],
          class_name: "User"
          })
      end

      subject { obj.send(:assign_defaults,attributes) }

      it "should merge project_type in attributes" do
        expect(subject).not_to include(project_type: 'basic')
      end
    end

    context "when model is 'Project'" do
      let(:attributes) { { name: "project_name", cause_id: 1, description: 'test project desc' } }
      let(:import_type) { 'project' }

      before do
        ImportDefinition.any_instance.stubs(:project)
          .returns({
          default_values: { project_type: 'basic' },
          alias_attributes: [ ],
          class_name: "Project"
          })
      end

      subject { obj.send(:assign_defaults,attributes) }

      it "should not merge entity in attributes" do
        expect(subject).not_to include(:entity_id)
      end

      it "should merge project_type in attributes" do
        expect(subject).to include(project_type: 'basic')
      end

    end
  end

  describe "#new_model" do
    let(:obj) { NfgCsvImporter::ImportService.new(imported_for:entity,type:import_type) }

    context "when model is subscriber" do
      let(:attributes) { { email: "first@mail.com", first_name: 'fname', last_name: 'lname' } }


      before do
        ImportDefinition.any_instance.stubs(:user)
          .returns({
          default_values: { },
          alias_attributes: [],
          class_name: "User"
          })
      end

      subject { obj.send(:new_model) }

      it "should assign the entity id" do
        expect(subject.entity_id).to eq(entity.id)
      end
    end
  end

  describe "#headers_valid?" do

    subject { import_service.headers_valid? }

    before(:each) do
      import_service.stubs(:all_headers_are_string_type?).returns(all_headers_are_string_type)
      import_service.stubs(:all_column_rules_valid?).returns(all_column_rules_valid)
    end

    let(:all_headers_are_string_type) { true }
    let(:all_column_rules_valid) { true }

    context "headers are valid" do
      it { expect(subject).to be }
    end

    context "headers are not string type" do
      let(:all_headers_are_string_type) { false }
      it { expect(subject).not_to be }
    end

    context "invalid column rules" do
      let(:all_column_rules_valid) { false }

      it { expect(subject).not_to be }
    end
  end

  describe "#all_column_rules_valid?" do
    before do
      import_service.stubs(:column_validation_rules).returns(column_validation_rules)
    end

    subject { import_service.all_column_rules_valid? }

    context 'when there are no rules supplied with the definition' do
      let(:column_validation_rules) { [] }
      it "should be true" do
        expect(subject).to be
      end
    end

    context "when there are rules supplied with the definition and some of them are invalid" do
      before do
        column_validator.expects(:validate).with(import.fields_mapping).returns(false)
      end

      let(:column_validation_rules) { [column_validator] }

      it "should be false" do
        expect(subject).not_to be
      end
    end

    context "when there are rules supplied with the definition and all are valid" do
      before do
        column_validator.expects(:validate).with(import.fields_mapping).returns(true)
      end

      let(:column_validation_rules) { [column_validator] }

      it "should be true" do
        expect(subject).to be
      end
    end
  end

  describe "#valid_file_extension?" do
    subject { import_service.valid_file_extension? }

    before(:each) do
      import_service.stubs(:file_extension).returns(file_extension)
    end

    context "when file_extension is xls" do
      let(:file_extension) { '.xls' }
      it { expect(subject).to be }
    end

    context "when file_extension is jpeg" do
      let(:file_extension) { '.jpeg' }
      it { expect(subject).not_to be }
    end

  end

  describe "#no_of_records" do
    subject { import_service.no_of_records }

    it { expect(subject).to eq(3) }
  end

  describe "#no_of_error_records" do
    subject { import_service.no_of_error_records }
    before { import_service.stubs(:errors_list).returns(['error1']) }

    it { expect(subject).to eq(1) }
  end

  describe "#persist_valid_record(model_obj, index, row)" do
    before do
      import_service.errors_list = []
    end

    let(:model_obj) { Project.new }
    subject { import_service.send(:persist_valid_record, model_obj, 2,{}) }

    it "should call increment_counter for import records_processed field" do
      NfgCsvImporter::Import.expects(:increment_counter).with(:records_processed, import.id)
      subject
    end

    context "when model object is invalid" do
      let(:model_obj) { FactoryGirl.build(:user, first_name: '') }

      it "should call increment_counter for import number_of_records_with_errors & records_processed fields" do
        NfgCsvImporter::Import.expects(:increment_counter).with(:records_processed, import.id)
        NfgCsvImporter::Import.expects(:increment_counter).with(:number_of_records_with_errors, import.id)
        subject
      end
    end
  end

  describe "#run_time_limit_reached?" do
    subject { import_service.run_time_limit_reached? }
    before do
      import_service.stubs(:max_run_time).returns(max_run_time)
      import_service.stubs(:run_time).returns(run_time)
    end

    context 'when run_time > max_run_time' do
      let(:max_run_time) { 100}
      let(:run_time) { 110}

      it 'returns true' do
        expect(subject).to be
      end
    end

    context 'when run_time = max_run_time' do
      let(:max_run_time) { 100}
      let(:run_time) { 100}

      it 'returns true' do
        expect(subject).to be
      end
    end

    context 'when run_time < max_run_time' do
      let(:max_run_time) { 110}
      let(:run_time) { 100}

      it 'returns false' do
        expect(subject).not_to be
      end
    end
  end

  describe "#run_time" do
    before { import_service.stubs(:start_timestamp).returns(10.seconds.ago.to_i) }
    subject { import_service.send(:run_time) }

    it 'returns seconds since starting timestamp' do
      expect(subject).to eq 10
    end
  end

  describe "#mark_start_time" do
    subject { import_service.send(:mark_start_time) }

    it 'sets start_timestamp to current timestamp' do
      expect { subject }.to change { import_service.start_timestamp }.from(nil).to(Time.zone.now.to_i)
    end
  end
end