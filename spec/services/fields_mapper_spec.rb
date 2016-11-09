require 'rails_helper'

describe NfgCsvImporter::FieldsMapper do
  before do
    ::ImportDefinition.any_instance.expects(:send).with("user").at_least(1).returns(import_definition)
  end
  let(:fields_mapper) { NfgCsvImporter::FieldsMapper.new(import) }
  let(:import) { create(:import, import_file: File.open("spec/fixtures/users_for_fields_mapping_test.xls")) }
  let(:field_aliases) { nil }
  let(:mapped_fields) { fields_mapper.call }
  let(:subject) { mapped_fields[column_name] }

  context "when the definition has not field_aliases" do
    let(:import_definition) { import_definition_base.delete_if { |k,v| k == :field_aliases } }

    context "when the header directly matches a field name" do
      let(:column_name) { "first_name" }
      it "the mapped field should be the field" do
        expect(subject).to eq("first_name")
      end
    end

    context "when the header matches the humanized downcased form of the field" do
      let(:column_name) { "first name" }

      it "the mapped field should be the field" do
        expect(subject).to eq("first_name")
      end
    end

    context "when the downcased header matches the humanized downcased form of the field" do
      let(:column_name) { "First Name" }

      it "the mapped field should be the field" do
        expect(subject).to eq("first_name")
      end
    end

    context "when the header matches the field with underscores removed" do
      let(:column_name) { "firstname" }

      it "the mapped field should be the field" do
        expect(subject).to eq("first_name")
      end
    end
  end

  context "when the definition has field aliases" do
    let(:import_definition) { import_definition_base }
    let(:field_aliases) { { "first_name" => ["first"]} }

    context "and the alias is a match for the header column name" do
      let(:column_name) { "donor first name" }
      it "should return the field_name in the" do
        expect(subject).to eq("first_name")
      end
    end

    context "and the alias is a match for more than one header" do
      let(:column_name) { "donor first name" }
      let(:field_aliases) { { "first_name" => ["first"], "contact_first_name" => ["first"]} }
      it "should return the first match" do
        expect(subject).to eq("first_name")
      end
    end

    context "and the alias has many options but none that match the " do
      let(:column_name) { "Street Address" }
      let(:field_aliases) { { "first_name" => ["first", "donor first name"], "last_name" => ["last", "donor last name"], "salutation" => ["prefix"], "amount" => ["amount"] } }

      it "should return nil" do
        expect(subject).to eq(nil)
      end

    end
  end
end

def import_definition_base
  {
    required_columns: %w{ email },
    optional_columns: %w{ first_name last_name phone },
    default_values: { "first_name" => lambda { |row| row["email"][/[^@]+/] } },
    class_name: "User",
    alias_attributes: [],
    column_descriptions: {},
    field_aliases: field_aliases,
    description: %Q{Allows you to import subscribers that then can receive daily, weekly, or newsletter emails. All of the columns listed above must be included in your file. Only the Email column is required to have a value. If first_name is blank, the system will set it to the text prior to the @ in the email.}
  }
end