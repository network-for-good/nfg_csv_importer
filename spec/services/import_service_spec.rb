require 'rails_helper'
require 'roo'
describe NfgCsvImporter::ImportService do

	let(:entity) { create(:entity) }
	let(:import_type) { "user" }
  let(:class_to_be_imported) { import_type.capitalize.constantize }
	let(:file_type) { 'csv' }

	let(:file) do
		import.import_file
	end

	let(:row_data) {["pavan@gmail.com","A Gilbert","William"]}
	let(:header_data) {["email" ,"first_name","last_name"]}
	let(:file_name) {"/subscribers.csv"}
	let(:admin) {  FactoryGirl.create(:user)}
	let(:import_service) { NfgCsvImporter::ImportService.new(imported_for: entity, type: import_type, file: file, imported_by: admin, import_record: import)}
	let(:import) { FactoryGirl.build(:import, import_file: File.open("spec/fixtures#{file_name}"))}

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
			expect(subject.import_definition.class_name).to eq import_type.camelize
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

        context "when the model isn't active record (unlikely to ever happen but just to be safe" do
          let(:non_model_object) { mock("NonModelObject") }


          it "leaves importable empty" do
            User.any_instance.stubs(:save).returns(non_model_object)
            expect { subject.import }.to raise_error(ActiveRecord::RecordInvalid)
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

		end

		context "when default values present" do
			before do
				ImportDefinition.any_instance
								.stubs(:user)
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
			  let(:default_value) { lambda { |row| row["email"][/[^@]+/] } }

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
			import_service.stubs(:header_has_all_required_columns?).returns(header_has_all_required_columns)
			import_service.stubs(:unknown_columns).returns(unknown_columns)
		end

		let(:all_headers_are_string_type) { true }
		let(:header_has_all_required_columns) { true }
		let(:unknown_columns) { [] }

		context "headers are valid" do
			it { expect(subject).to be }
		end

		context "headers are not string type" do
			let(:all_headers_are_string_type) { false }
			it { expect(subject).not_to be }
		end

		context "missing required columns" do
			let(:header_has_all_required_columns) { false }
			it { expect(subject).not_to be }
		end

		context "unknown columns present" do
			let(:unknown_columns) { ['unknown'] }
			it { expect(subject).not_to be }
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

	describe "#unknown_columns" do
		subject { import_service.unknown_columns }

		before(:each) do
			import_service.stubs(:stripped_headers).returns(stripped_headers)
			import_service.stubs(:all_valid_columns).returns(all_valid_columns)
		end

		let(:stripped_headers) { ['unknown', 'name', 'email'] }
		let(:all_valid_columns) { ['name', 'email']  }

		context "when there are unknown columns" do
			it { expect(subject).to eq(['unknown']) }
		end

		context "when there is no unknown columns" do
			let(:stripped_headers) { ['name', 'email']  }
			it { expect(subject).to eq([]) }
		end
	end

	describe "#missing_required_columns" do
		subject { import_service.missing_required_columns }

		before(:each) do
			import_service.stubs(:stripped_headers).returns(stripped_headers)
			import_service.stubs(:required_columns).returns(required_columns)
		end

		let(:stripped_headers) { ['name', 'email', 'address'] }
		let(:required_columns) { ['name', 'email']  }

		context "when all required columns are present" do
			it { expect(subject).to eq([]) }
		end

		context "when required columns are missing" do
			let(:required_columns) { ['name', 'email', 'contact']  }
			it { expect(subject).to eq(['contact']) }
		end
	end

	describe "#validate_object(object)" do
		subject { import_service.send(:validate_object,object) }
    let(:object) { FactoryGirl.build(:user, email: email) }

    context "when object is invalid" do
    	let(:email) { '' }

    	it { expect(subject).not_to be }
    end

    context "when object is valid" do
    	let(:email) { 'pavan@networkforgood.com' }

    	it { expect(subject).to be }
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
