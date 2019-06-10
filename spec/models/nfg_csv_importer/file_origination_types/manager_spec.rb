require "rails_helper"

RSpec.describe NfgCsvImporter::FileOriginationTypes::Manager do
  let(:manager) { described_class.new(config) }
  let(:config) { OpenStruct.new(additional_file_origination_types: file_types) }

  describe '#types' do
    subject { manager.types }

    context "when the config setting `additional_file_origination_types` is nil" do
      let(:file_types) { nil }
      it 'should return an empty array' do
        expect(subject).to eq([])
      end
    end

    context "when the config setting `additional_file_origination_types` is an empty array" do
      let(:file_types) { [] }
      it 'should return an empty array' do
        expect(subject).to eq([])
      end
    end

    context "when the config setting `additional_file_origination_types` contains an array of symbols" do
      context "and there is no file named for it in the host apps imports/file_origination_types folder" do
        let(:file_types) { [:my_custom_app] }
        it 'should raise an error' do
          expect { subject }.to raise_error(NfgCsvImporter::FileOriginationTypes::TypeNotDefinedError)
        end
      end

      context "and there is no file named for it in the host apps imports/file_origination_types folder" do
        let(:file_types) { [:constant_contact] }
        it 'return an array of FileOriginationType objects' do
          expect(subject).to be_a(Array)
          expect(subject.first).to be_a(NfgCsvImporter::FileOriginationTypes::FileOriginationType)
        end
      end
    end
  end
end