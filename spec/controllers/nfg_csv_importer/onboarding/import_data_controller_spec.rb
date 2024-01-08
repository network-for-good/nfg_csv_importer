require 'rails_helper'

describe NfgCsvImporter::Onboarding::ImportDataController do

  let(:params) do
    {
      params: {
                import_id: import.id,
                use_route: :nfg_csv_importer,
                id: step,
                nfg_csv_importer_onboarding_import_data_file_origination_type_selection: { file_origination_type: name}
              }
     }
  end
  let!(:import) { create(:import, :with_pre_processing_files, status: 'uploaded', import_file: File.open("spec/fixtures/individual_donation.csv" ), fields_mapping: mapping) }
  let(:current_step) { step }
  let(:file_origination_type) { mock('paypal') }
  let(:mapping) { { 'some' => 'mapping'} }
  let(:requires_file) { true }
  let(:type_sym) { name }
  before do
    NfgCsvImporter::FileOriginationTypes::Manager.any_instance.stubs(:type_for).returns(file_origination_type)
    file_origination_type.expects(:skip_steps).at_least_once
    file_origination_type.stubs(:requires_post_processing_file).returns(requires_file)
    file_origination_type.stubs(:formatted_type_sym).returns(type_sym)
    file_origination_type.stubs(:type_sym).returns(type_sym)
  end

  render_views

  describe "#update" do
    let(:step) { 'preview_confirmation' }
    let(:name) { 'test.csv' }
    subject { put :update, params }


    context 'when the step is preview confirmation' do
      context "when a different user is completing the import than started it" do
        before do
          NfgCsvImporter::ProcessImportJob.expects(:perform_async)
          NfgCsvImporter::ImportMailer.expects(:send_import_result).returns(mock('mailer', deliver_now: nil))
          controller.stubs(:current_user).returns(current_user)
          controller.stubs(:entity).returns(entity)
          import.uploaded!
        end
        
        let!(:import) { create(:import, :with_pre_processing_files, imported_by: original_user, imported_for: entity, import_file: File.open("spec/fixtures/individual_donation.csv" ), fields_mapping: mapping) }
        let(:original_user) { create(:user, entity: entity)  } 
        let(:current_user) { create(:user, entity: entity)  }
        let(:entity) { create(:entity) }
        
        it 'changes the import imported_by to whoever submits it' do
          expect { subject }.to change{ import.reload.imported_by_id }.from(original_user.id).to(controller.current_user.id)
        end
      end
    end

    context 'when the current step is upload_post_processing' do
      let(:step) { 'upload_post_processing' }

      it 'resets statistics' do
        NfgCsvImporter::Import.any_instance.expects(:update_column).with(:statistics, nil)
        subject
      end
    end

    context 'when the current step is upload_preprocessing' do
      let(:step) { 'upload_preprocessing' }
      let(:post_preprocessing_upload_hook) { mock('post_preprocessing_upload_hook', call: mock('result', status: :success)) }

      before { file_origination_type.expects(:post_preprocessing_upload_hook).returns(post_preprocessing_upload_hook) }

      it 'resets statistics' do
        NfgCsvImporter::Import.any_instance.expects(:update_column).with(:statistics, nil)
        subject
      end
    end

    context 'when the file origination type changes' do

      let(:step) { 'file_origination_type_selection'}
      let(:file_origination_type) { mock('file_origination_type') }
      let(:requires_file) { false }
      let(:type_sym) { 'some-name' }
      subject { put :update, params }

      it 'should reset import attributes' do
        expect(import.reload.import_file.file.present?).to be_truthy

        ActiveStorage::Attachment.any_instance.expects(:purge)
        expect{ subject }.to change { import.reload.fields_mapping }.from(mapping).to(nil)
        expect(import.reload.import_file.file.present?).to be_falsey
      end
    end
  end
end
