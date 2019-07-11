require "rails_helper"

describe NfgCsvImporter::ActiveStorageHelper do
  let(:signed_id) { 'some-id' }
  let(:record) { mock('record') }

  describe '#find_record_using_signed_id' do
    subject { described_class.find_by_signed_id(signed_id) }

    before { ActiveStorage::Blob.stubs(:find_signed).returns(record) }

    it 'calls active storage blob' do
      expect(subject).to eq(record)
    end
  end

  describe '#find_record_using_signed_id' do
    let(:filename) { mock('filename') }
    let(:extension) { 'csv' }

    subject { described_class.get_file_extension(record) }

    before do
      record.expects(:filename).returns(filename)
    end

    context 'when the record has a filename' do
      before { filename.expects(:extension).returns(extension) }

      it { is_expected.to eq extension }
    end

    context 'when the record does not have a filename' do
      let(:filename) { nil }

      it { is_expected.to eq nil }
    end
  end
end
