require 'rails_helper'

describe NfgCsvImporter::Onboarding::ImportData::UploadPreprocessingForm do
  let(:form) { described_class.new(import) }
  let(:entity) { create(:entity) }
  let(:pre_processing_files) { [signing_id] }
  let(:admin) {  create(:user) }
  let(:import_type) { 'some-type' }
  let(:import) { FactoryGirl.build(:import, imported_for: entity, import_type: import_type, imported_by: admin, status: 'pending') }
  let(:import_file_validateable_host) { form }
  let(:params) { { pre_processing_files: pre_processing_files } }
  let(:record) { mock('record') }
  let(:filename) { mock('filename') }
  let(:extension) { 'csv' }
  let(:signing_id) { 'valid-1' }

  subject { import_file_validateable_host.validate(params) }

  context "validating the file" do
    before do
      ActiveStorage::Blob.stubs(:find_signed).with(signing_id).returns(record)
      record.expects(:filename).returns(filename)
      filename.expects(:extension).returns(extension)
    end

    context 'when there is a valid file type' do
      it { expect(subject).to be }
    end

    context 'when there is an invalid file type' do
      let(:extension) { 'cool' }
      let(:signing_id) { 'invalid-1' }
      let(:pre_processing_files) { [signing_id] }

      it { expect(subject).not_to be }
    end
  end
end
