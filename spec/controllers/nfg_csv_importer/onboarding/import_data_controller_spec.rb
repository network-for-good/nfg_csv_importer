require 'rails_helper'

describe NfgCsvImporter::Onboarding::ImportDataController do

  let(:params) { { params: { import_id: import.id, use_route: :nfg_csv_importer, id: step } } }
  let!(:import) { create(:import, :with_pre_processing_files, status: 'uploaded', import_file: File.open("spec/fixtures/individual_donation.csv" )) }
  let(:current_step) { step }
  let(:file_origination_type) { mock('paypal', name: 'test.csv') }

  before do
    NfgCsvImporter::FileOriginationTypes::Manager.any_instance.stubs(:type_for).returns(file_origination_type)
    file_origination_type.expects(:skip_steps).at_least_once
    file_origination_type.stubs(:requires_post_processing_file).returns(true)
  end

  render_views

  describe "#update" do
    let(:step) { 'preview_confirmation' }

    subject { put :update, params }

    before { NfgCsvImporter::ProcessImportJob.expects(:perform_later) }

    it "should send mail on import is queued" do
      NfgCsvImporter::ImportMailer.expects(:send_import_result).returns(mock('mailer', deliver_now: nil))
      subject
    end

    context 'when exit parameter is defined' do
      let(:params) { { params: { import_id: import.id, exit: true, use_route: :nfg_csv_importer, id: step } } }

      before { session[:onboarding_session_id] = import.id }
      it 'should redirect to imports path' do
        expect(subject).to redirect_to imports_path
      end

      it 'should clear onboarding session' do
        expect{ subject }.to change { session[:onboarding_session_id] }.from(import.id).to(nil)
      end
    end
  end
end
