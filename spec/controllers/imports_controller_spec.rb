require 'rails_helper'

shared_examples_for "an action that requires authorization" do
  context "when the import type is not viewable by the user" do
    let(:can_be_viewed_by) { false }

    it "should redirect the user to the index page" do
      expect(subject).to redirect_to(imports_path)
    end
  end
end

shared_examples_for "an action that requires an uploading status" do
  context 'when the import is not uploaded' do
    before { import.processing! }

    it "should redirect the user to the import show page" do
      expect(subject).to redirect_to(import_path(import))
      expect(flash[:error]).to eq I18n.t('import.cant_edit_or_reprocess')
    end
  end
end

describe NfgCsvImporter::ImportsController do

  let(:entity) { create(:entity) }
  let(:user) { create(:user) }
  let(:import_type) { 'users' }
  let(:file_name) {"spec/fixtures/subscribers.csv"}
  let(:import) { assigns(:import) }
  let(:params) { { params: { import_type: import_type, use_route: :nfg_csv_importer } } }
  let(:file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload(file_name, 'text/csv')
  end
  let(:can_be_viewed_by) { true }

  before do
    controller.stubs(:current_user).returns(user)
    controller.stubs(:entity).returns(entity)
    NfgCsvImporter::Import.any_instance.stubs(:can_be_viewed_by).with(user).returns(can_be_viewed_by)
  end

  render_views

  it "create action should render new template on import error" do
    post :create, params
    expect(response).to render_template(:new)
  end

  describe "#create" do
    subject { post :create, params }

    it_behaves_like "an action that requires authorization"

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
        NfgCsvImporter::ImportService.any_instance.expects(:maybe_set_import_number_of_records).returns(:true)
        subject
      end

      it "should redirect to the edit import path with the column count included" do
        expect(subject).to redirect_to(edit_import_path(import, mapped_column_count: import.column_stats[:mapped_column_count]))
      end

    end

    context "when the import is not valid" do
      before do
        NfgCsvImporter::Import.any_instance.stubs(:valid?).returns(false)
        NfgCsvImporter::Import.any_instance.stubs(:errors).returns(stub(full_messages: [error_message], "any?" => true))
      end

      let(:error_message) { "The file does not have the correct format" }

      it "should display the message and not create a new import record" do
        expect { subject }.not_to change(NfgCsvImporter::Import, :count)
        expect(response.body).to have_text(error_message)
      end
    end
  end

  describe "#destroy" do
    let!(:import) { create(:import, imported_for: entity, status: 'complete') }
    let(:params) { { params: { id: import.id, use_route: :nfg_csv_importer } } }
    let!(:imported_records) { create_list(:imported_record, 3, import: import) }

    before do
      NfgCsvImporter::ImportedRecord.stubs(:batch_size).returns(2)
      NfgCsvImporter::DestroyImportJob.stubs(:perform_later).returns(mock)
      controller.stubs(:entity).returns(entity)
    end

    subject { delete :destroy, params }

    it_behaves_like "an action that requires authorization"

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

    it 'redirects back to index with a success flash message' do
      subject
      expect(response).to redirect_to imports_path
      expect(flash[:success]).to eq I18n.t(:success, number_of_records: 3, scope: [:import, :destroy])
    end

    context "when the import can't be deleted by the current user" do
      before do
        NfgCsvImporter::Import.any_instance.stubs(:can_be_deleted?).with(user).returns(false)
      end

      it 'redirects back to show with an error flash message' do
        subject
        expect(response).to redirect_to import_path(import)
        expect(flash[:error]).to eq I18n.t(:cannot_delete, scope: [:import, :destroy])
      end
    end
  end

  describe "#new" do

    subject { get :new, params }

    it_behaves_like "an action that requires authorization"

    it "should assign subscriber import service" do
      subject
      expect(import.import_type).to eq(import_type)
    end

    it "should assign import status" do
      subject
      expect(import.status).to eq("queued")
    end

    it "new action should render new template" do
      subject
      expect(response).to render_template(:new)
    end
  end

  describe "#update" do
    let!(:import) { create(:import, imported_for: entity) }
    let(:params) { { params: { id: import.id, use_route: :nfg_csv_importer } } }

    subject { patch :update, params}

    it_behaves_like "an action that requires authorization"
    it_behaves_like "an action that requires an uploading status"
  end

  describe "#edit" do
    let!(:import) { create(:import, imported_for: entity) }
    let(:params) { { params: { id: import.id, use_route: :nfg_csv_importer } } }

    subject { get :edit, params}

    it_behaves_like "an action that requires authorization"
    it_behaves_like "an action that requires an uploading status"
  end

  describe "#template" do
    subject { get :template, params}

    it "generate CSV" do
      subject
      expect(response.header['Content-Type']).to include 'text/csv'
      expect(response.body).to include('email,first_name,last_name,full_name')
    end
  end

  describe "#reset_onboarder_session" do
    subject { get :reset_onboarder_session, params }

    let(:session_id) { 234 }
    let(:import_id) { 123 }

    before do
      session[:onboarding_session_id] = session_id
      session[:onboarding_import_data_import_id] = import_id
    end

    it 'redirects to the imports path' do
      expect(subject).to redirect_to :action => :index
    end

    it 'resets user session id' do
      expect{subject}.to change { session[:onboarding_session_id] }.from(session_id).to(nil)
    end

    it 'resets user session onboarding_import_data_import_id' do
      expect{subject}.to change { session[:onboarding_import_data_import_id] }.from(import_id).to(nil)
    end
  end

  describe '#download_attachments' do
    let(:params) { { params: { import_id: import.id } } }
    subject { post :download_attachments, params: { import_id: import.id, import_type: import_type, use_route: :nfg_csv_importer } }

    context 'when pre_processing_files exist' do

      let!(:import) { create(:import, :with_pre_processing_files, imported_for_id: entity.id) }

      it 'calls create zip service' do
        NfgCsvImporter::CreateZipService.any_instance.expects(:call)
        subject
      end
    end

    context 'when pre_processing_files do not exist' do
      let(:import) { create(:import, imported_for_id: entity.id) }

      it 'does not send a file in the response' do
        NfgCsvImporter::ImportsController.any_instance.expects(:send_file).never
        subject
      end

      it 'returns status 404' do
        subject
        expect(response.status).to eq(404)
      end
    end
  end
end
