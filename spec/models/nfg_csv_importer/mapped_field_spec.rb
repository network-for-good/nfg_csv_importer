require "rails_helper"

describe NfgCsvImporter::MappedField do
  let(:mapped_field) { NfgCsvImporter::MappedField.new(header_column: header_column, field: field) }
  let(:header_column) { "first_name" }
  let(:field) { nil }

  describe "#status" do
    subject { mapped_field.status }

    context 'when the field is nil' do
      it "should be unmapped" do
        expect(subject).to eq(:unmapped)
      end
    end

    context 'when the field is blank' do
      let(:field) { "" }
      it "should be unmapped" do
        expect(subject).to eq(:unmapped)
      end
    end

    context "when the field has a non blank value" do
      let(:field) { "first_name" }
      it "should be mapped" do
        expect(subject).to eq(:mapped)
      end
    end

    context "when the field is the ignore column value" do
      let(:field) { NfgCsvImporter::Import.ignore_column_value }
      it "should be ignored" do
        expect(subject).to eq(:ignored)
      end
    end
  end

  describe "#name" do
    subject { mapped_field.name }

    it "should equal the header_column" do
      expect(subject).to eq(header_column)
    end
  end

  describe "mapped_to" do
    subject { value }
  end
end