require 'rails_helper'

describe NfgCsvImporter::ImportsController do

  let(:entity) { create(:entity) }
  let(:user) { create(:user) }
  let(:import_type) { 'user' }
  let(:file_name) {"spec/fixtures/subscribers.csv"}
  let(:import) { assigns(:import) }
  let(:params) { { import_type: import_type, use_route: :nfg_csv_importer } }
  let(:file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload(file_name, 'text/csv')
  end

  before do
    controller.stubs(:current_user).returns(user)
    controller.stubs(:entity).returns(entity)
  end

  render_views

  it "should assign subscriber import service" do
    get :new, params
    expect(import.import_type).to eq(import_type)
  end

  it "should assign import status" do
    get :new, params
    expect(import.status).to eq("queued")
  end

  it "new action should render new template" do
    get :new, params
    expect(response).to render_template(:new)
  end

  it "create action should render new template on import error" do
    post :create, params
    expect(response).to render_template(:new)
  end


  describe "#create" do
    subject { post :create, params }
    context "when the import is valid" do
      before do
        NfgCsvImporter::Import.any_instance.stubs(:valid?).returns(true)
        NfgCsvImporter::FieldsMapper.expects(:new).returns(mock(call: fields_mapping))
        NfgCsvImporter::Import.any_instance.stubs(:number_of_records).returns(3)
      end

      let(:import) { NfgCsvImporter::Import.last }
      let(:fields_mapping) { { "foo" => "bar", "baz" => "bing", "bat" => nil } }
      let(:mapped_column_count) { 2 } # the number of values in the fields_mapping hash

      it { expect { subject }.to change(NfgCsvImporter::Import, :count).by(1) }

      it "should redirect to the edit page and include the number of mapped columns in the url" do
        subject
        expect(response).to redirect_to(edit_import_path(import, mapped_column_count: mapped_column_count))
      end

      it "should assign the value of the fields mapper to the import" do
        NfgCsvImporter::Import.any_instance.expects(:update).with(has_entry(fields_mapping: fields_mapping)).at_least_once #when the importer is created
        subject
      end

      it "should set the number of rows" do
        NfgCsvImporter::Import.any_instance.expects(:service).returns(mock(maybe_set_import_number_of_records: true)) #when the importer is created
        subject
      end

      it "should redirect to the edit import path with the column count included" do
        expect(subject).to redirect_to(edit_import_path(import, mapped_column_count: import.column_stats[:mapped_column_count]))
      end

    end

    context "when the import is not valid" do
      before do
        NfgCsvImporter::Import.any_instance.stubs(:valid?).returns(false)
      end

      it { expect { subject }.not_to change(NfgCsvImporter::Import, :count) }


    end
  end

  describe "#destroy" do
    let!(:import) { create(:import, imported_for: entity) }
    let(:params) { { id: import.id, use_route: :nfg_csv_importer } }
    let!(:imported_records) { create_list(:imported_record, 3, import: import) }

    before do
      NfgCsvImporter::ImportedRecord.stubs(:batch_size).returns(2)
      NfgCsvImporter::DestroyImportJob.stubs(:perform_later).returns(mock)
      controller.stubs(:entity).returns(entity)
    end

    subject { delete :destroy, params }

    it "adds the job to the queue" do
      NfgCsvImporter::DestroyImportJob.expects(:perform_later).twice
      subject
    end

    it "does not delete the imported records" do
      NfgCsvImporter::ImportedRecord.any_instance.expects(:destroy).never
      subject
    end

    it "sets the import's status to deleting" do
      subject
      expect(import.reload.status).to eql("deleting")
    end
  end
end
