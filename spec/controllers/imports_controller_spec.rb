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


  context "#create" do

    before do
      NfgCsvImporter::Import.any_instance.stubs(:valid?).returns(true)
      NfgCsvImporter::ProcessImportJob.stubs(:perform_later).returns(mock)
    end

    subject { post :create, params }

    it "should redirect when import is successfully placed in queue" do
      subject
      expect(response).to redirect_to(import)
    end

    it "should add import job to queue" do
      NfgCsvImporter::ProcessImportJob.expects(:perform_later)
      subject
      #expect(NfgCsvImporter::Import).not_to have_queued(:imports_queue, import.id)
    end

    it "should display success message" do
      subject
      expect(flash[:notice]).to eq I18n.t('flash_messages.import.create.notice')
    end
  end


end