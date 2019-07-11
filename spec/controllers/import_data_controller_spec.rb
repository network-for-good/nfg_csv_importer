require 'rails_helper'

describe NfgCsvImporter::Onboarding::ImportDataController do

  let(:params) { { params: { use_route: :nfg_csv_importer, reset_import: reset_import, id: step } } }
  let(:step) { 'file_origination_type_selection' }
  let(:session_id) { 'some-id' }
  render_views

  describe "#show" do
    subject { get :show, params }

    let(:reset_import) { true }

    before do
      # when new session is created, assign a mock id for ease of testing
      ::Onboarding::Session.any_instance.stubs(:id).returns(session_id)
      session[:onboarding_session_id] = session_id
    end

    context 'when the reset_import param is passed' do
      it "should clear the onboarding_session_id" do
        expect{ subject }.to change{ session[:onboarding_session_id] }.from(session_id).to(nil)
      end
    end

    context 'when the reset_import param is false' do
      let(:reset_import) { false }

      it "should not clear the onboarding_session_id" do
        expect{ subject }.to_not change{ session[:onboarding_session_id] }
      end
    end
  end
end
