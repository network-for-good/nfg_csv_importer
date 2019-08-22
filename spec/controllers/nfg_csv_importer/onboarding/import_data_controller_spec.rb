require 'rails_helper'

describe NfgCsvImporter::Onboarding::ImportDataController do

  let(:params) do
    {
      params: {
                import_id: import.id,
                use_route: :nfg_csv_importer,
                id: step,
                nfg_csv_importer_onboarding_import_data_upload_preprocessing: { note: 'some-note' },
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
  end

  render_views

  describe "#update" do
    let(:step) { 'preview_confirmation' }
    let(:name) { 'test.csv' }
    subject { put :update, params }

    context 'when processing an import' do
      before { NfgCsvImporter::ProcessImportJob.expects(:perform_later) }

      it "should send mail on import is queued" do
        NfgCsvImporter::ImportMailer.expects(:send_import_result).returns(mock('mailer', deliver_now: nil))
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
