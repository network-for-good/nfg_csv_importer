require "rails_helper"

RSpec.describe NfgCsvImporter::FileOriginationTypes::Manager do
  let(:manager) { described_class.new(config) }
  let(:file_type_class) { NfgCsvImporter::FileOriginationTypes::FileOriginationType }
  let(:config) { OpenStruct.new(additional_file_origination_types: file_types) }
  let(:file_types) { [] }

  let(:default_file_type_sym) { NfgCsvImporter::FileOriginationTypes::Manager::DEFAULT_FILE_ORIGINATION_TYPE_SYM }

  describe '.type_for' do
    subject { described_class.type_for(file_type_name) }
    let(:file_type_name) { "test_type" }

    it 'should instantiate itself, passing in the configuration, and then calling type_for with the supplied argument' do

    end
  end
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
        let(:file_type_sym) { :paypal }

        it 'return an array of FileOriginationType objects' do
          expect(subject).to be_a(Array)
          expect(subject.first).to be_a(file_type_class)
        end

        it 'the first should represent the first additional file origination type' do
          expect(subject.first.type_sym).to eq(file_type_sym)
        end

        it 'the last element should be the SelfImportCsvXls' do
          expect(subject.last.type_sym).to eq(default_file_type_sym)
        end
      end

      context "and it includes  default file origination type" do
        let(:file_types) { [NfgCsvImporter::FileOriginationTypes::Manager::DEFAULT_FILE_ORIGINATION_TYPE_SYM] }

        it "does not duplicate the types" do
          expect(subject.length).to eq(1)
          expect(subject.first.type_sym).to eq(default_file_type_sym)
        end
      end
    end
  end

  describe '#type_for' do
    subject { manager.type_for(file_type_name) }
    let(:file_types) { [:paypal] }

    context "when the supplied name matches one of the types" do
      let(:file_type_name) { "paypal" }

      it 'returns a type whose name matches' do
        expect(subject).to be_a(file_type_class)
        expect(subject.type_sym).to eq(file_type_name.to_sym)
      end
    end

    context "when the supplied name does not match one of the types" do
      let(:file_type_name) { 'not_a_type' }

      it 'should return nil' do
        expect(subject).to be_nil
      end
    end

    context "when the name matches the default type" do
      let(:file_type_name) { NfgCsvImporter::FileOriginationTypes::Manager::DEFAULT_FILE_ORIGINATION_TYPE_SYM }

      it 'should return the file type for the default type' do
        expect(subject).to be_a(file_type_class)
        expect(subject.type_sym).to eq(file_type_name.to_sym)
      end
    end
  end

  describe "#types_available_for" do
    let(:user) { create(:user) }
    subject { manager.types_available_for(user: user) }

    it 'calls the file type to see if current user can access it' do
      "NfgCsvImporter::FileOriginationTypes::#{default_file_type_sym.to_s.camelize}".constantize.expects(:can_be_viewed_by?).with(user)
      subject
    end
  end
end
