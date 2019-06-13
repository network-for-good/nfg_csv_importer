require "rails_helper"

RSpec.describe NfgCsvImporter::FileOriginationTypes::Manager do
  let(:manager) { described_class.new(config) }
  let(:config) { OpenStruct.new(additional_file_origination_types: file_types) }

  let(:default_file_type_sym) { NfgCsvImporter::FileOriginationTypes::Manager::DEFAULT_FILE_ORIGINATION_TYPE_SYM }

  describe '#types' do
    subject { manager.types }

    context "when the config setting `additional_file_origination_types` is nil" do
      let(:file_types) { nil }

      it 'should return an array with a single element of SelfImportCsvXls (default file origination type)' do
        expect(subject.length).to eq(1)
        expect(subject.first.type_sym).to eq(default_file_type_sym)
      end
    end

    context "when the config setting `additional_file_origination_types` is an empty array" do
      let(:file_types) { [] }

      it 'should return an array with a single element of SelfImportCsvXls (default file origination type)' do
        expect(subject.length).to eq(1)
        expect(subject.first.type_sym).to eq(default_file_type_sym)
      end
    end

    context "when the config setting `additional_file_origination_types` contains an array of symbols" do
      context "and there is no file named for it in the host apps imports/file_origination_types folder" do
        let(:file_types) { [:my_custom_app] }
        it 'should raise an error' do
          expect { subject }.to raise_error(NfgCsvImporter::FileOriginationTypes::TypeNotDefinedError)
        end
      end

      context "and there is a file named for it in the host apps imports/file_origination_types folder" do
        let(:file_types) { [file_type_sym] }
        let(:file_type_sym) { :constant_contact }

        it 'return an array of FileOriginationType objects' do
          expect(subject).to be_a(Array)
          expect(subject.first).to be_a(NfgCsvImporter::FileOriginationTypes::FileOriginationType)
        end

        it 'the first should represent the first additional file origination type' do
          expect(subject.first.type_sym).to eq(file_type_sym)
        end

        it 'the last element should be the SelfImportCsvXls' do
          expect(subject.last.type_sym).to eq(default_file_type_sym)
        end
      end
    end
  end
end