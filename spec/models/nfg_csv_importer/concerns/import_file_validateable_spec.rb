require "rails_helper"

class MockClass
  include NfgCsvImporter::Concerns::ImportFileValidateable
end

describe "NfgCsvImporter::Concerns::ActiveStorageHelper" do
  let(:signed_id) { 'some-id' }
  let(:record) { mock('record') }
  let(:valid_extensions) { %w[abc def] }
  let(:extension) { 'abc' }


  describe '#file_extension_invalid' do
    subject { MockClass.new.file_extension_invalid?(extension, valid_extensions) }

    context 'for a valid extension' do
      it { is_expected.to_not be }
    end

    context 'for an invalid extension' do
      let(:extension) { 'inv' }
      it { is_expected.to be }
    end
  end
end
