require 'rails_helper'

describe NfgCsvImporter::Onboarding::ImportData::UploadPreprocessingForm do
  let(:form) { described_class.new(import) }
  let(:entity) { create(:entity) }
  let(:pre_processing_files) { [valid_signing_id] }
  let(:admin) {  create(:user) }
  let(:import_type) { 'some-type' }
  let(:import) { FactoryGirl.build(:import, imported_for: entity, import_type: import_type, imported_by: admin, status: 'pending') }
  let(:import_file_validateable_host) { form }
  let(:params) { { pre_processing_files: pre_processing_files } }
  let(:record) { mock('record') }
  let(:filename) { mock('filename') }
  let(:extension) { 'csv' }
  let(:valid_signing_id) { 'valid-1' }
  let(:invalid_signing_id) { 'invalid-1' }

  subject { import_file_validateable_host.validate(params) }

  context "validating the file" do
    before do
      ActiveStorage::Blob.stubs(:find_signed).with(valid_signing_id).returns(record)
      record.expects(:filename).returns(filename)
      filename.expects(:extension).returns(extension)
    end

    it { expect(subject).to be }
  end

  context 'when there is an invalid file type' do
    let(:extension) { 'cool' }
    let(:pre_processing_files) { [invalid_signing_id] }

    before do
      ActiveStorage::Blob.stubs(:find_signed).with(invalid_signing_id).returns(record)
      record.expects(:filename).returns(filename)
      filename.expects(:extension).returns(extension)
    end

    it { expect(subject).not_to be }
  end
end
