require "rails_helper"

describe NfgCsvImporter::ColumnValidator do
  let(:column_validator) { NfgCsvImporter::ColumnValidator.new(rule) }
  let(:rule) { { type: "any", fields: ["first_name", "last_name"], message: "You must supply either a first_name or a full_name column"} }

  describe "#validate" do
    subject { column_validator.validate(fields_mapping) }
    context "with an 'any' rule" do
      context 'and the mapping contains none of the fields' do
        it "should be false" do
          expect(subject).not_to be
        end
      end

      context 'and the mapping contains one of the fields' do
        let(:fields_mapping) { { "Donor First Name" => "first_name" } }
        it "should be true" do
          expect(subject).to be
        end
      end

      context "and the mapping contains more than one of the fields" do
        let(:fields_mapping) { { "Donor First Name" => "first_name", "Name" => "full_name" } }

        it "should be true" do
          expect(subject).to be
        end
      end
    end

    context "with an 'all_if_any' type" do
      let(:rule) { { type: 'all_if_any', fields: ["donated_at", "amount", "payment_method"] } }
      context 'and the mapping does not contain any of the fields' do
        it "should be true" do
          expect(subject).to be
        end
      end

      context "and the mapping contains some but not all of the fields" do
        let(:fields_mapping) { { "Donation Amount" => "amount", "Donated At" => nil} }

        it "should be false" do
          expect(subject).not_to be
        end
      end

      context "and the mapping contains all of the fields" do
        let(:fields_mapping) { { "Donation Amount" => "amount", "Donation Date" => "donated_at", "How paid?" => "payment_method" } }

        it "should be true" do
          expect(subject).to be
        end
      end
    end
  end
end

def fields_mapping
  { "Donor First Name" => nil,
    "Donor Email" => "Email"}
end