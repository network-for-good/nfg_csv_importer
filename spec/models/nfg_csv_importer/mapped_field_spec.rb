require "rails_helper"

describe NfgCsvImporter::MappedField do
  let(:mapped_field) { NfgCsvImporter::MappedField.new(mapped_field_params) }
  let(:header_column) { "first_name" }
  let(:default_params) { { header_column: header_column, field: field } }
  let(:mapped_field_params) { default_params }
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

  describe "#mapped?" do
    before do
      mapped_field.stubs(:status).returns(status)
    end

    subject { mapped_field.mapped? }

    context 'when the status is :mapped' do
      let(:status) { :mapped }

      it "should be true" do
        expect(subject).to be
      end
    end

    context "when the status is not :mapped" do
      let(:status) { :unmapped }

      it "should be false" do
        expect(subject).not_to be
      end
    end
  end

  describe "#unmapped?" do
    before do
      mapped_field.stubs(:status).returns(status)
    end

    subject { mapped_field.unmapped? }

    context 'when the status is :unmapped' do
      let(:status) { :unmapped }

      it "should be true" do
        expect(subject).to be
      end
    end

    context "when the status is not :unmapped" do
      let(:status) { :mapped }

      it "should be false" do
        expect(subject).not_to be
      end
    end
  end

  describe "#ignored?" do
    before do
      mapped_field.stubs(:status).returns(status)
    end

    subject { mapped_field.ignored? }

    context 'when the status is :ignored' do
      let(:status) { :ignored }

      it "should be true" do
        expect(subject).to be
      end
    end

    context "when the status is not :ignored" do
      let(:status) { :mapped }

      it "should be false" do
        expect(subject).not_to be
      end
    end
  end

  describe "#name" do
    subject { mapped_field.name }

    it "should equal the header_column" do
      expect(subject).to eq(header_column)
    end
  end

  describe "#dom_id" do
    subject { mapped_field.dom_id }
    let(:header_column) { "Donor First Name" }

    it "should downcase and underscore the header name" do
      expect(subject).to eq("donor_first_name")
    end

    context 'when the field name contains special characters' do
      let(:header_column) { "Donor # of Donations" }

      it "should strip out the special characters" do
        expect(subject).to eq("donor__of_donations")
      end
    end
  end

  describe "#mergeable?" do
    subject { mapped_field.mergeable? }

    let(:mapped_field_params) { default_params.merge(merge_field_params) }
    let(:merge_field_params) { {} }

    context "when the field has not been mapped" do
      it "should be false" do
        expect(subject).not_to be
      end
    end

    context "when the field has been mapped" do
      let(:field) { "note" }

      context "when no list of mergeable fields is provided" do
        it "should be false" do
          expect(subject).not_to be
        end
      end

      context "when the list of mergeable fields is nil" do
        subject { mapped_field.mergeable? }
        let(:merge_field_params) { { fields_that_allow_multiple_mappings: nil } }

        it "should be false" do
          expect(subject).not_to be
        end
      end

      context "when the list of mergeable fields is an empty hash" do
        let(:merge_field_params) { { fields_that_allow_multiple_mappings: [] } }

        it "should be false" do
          expect(subject).not_to be
        end
      end

      context "when the list of mergeable fields contains values but not for the field referenced in the mapping" do
        let(:merge_field_params) { { fields_that_allow_multiple_mappings: ["other"] } }

        it "should be false" do
          expect(subject).not_to be
        end
      end

      context "when the list of mergeable fields contains values including the field references in the mapping" do
        let(:merge_field_params) { { fields_that_allow_multiple_mappings: ["other", "note"] } }

        it "should be true" do
          expect(subject).to be
        end
      end
    end
  end

  describe "#mapped_to" do
    subject { value }
  end
end