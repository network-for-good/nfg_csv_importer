require "rails_helper"

describe NfgCsvImporter::ImportDefinition do
  before do
    NfgCsvImporter::ImportDefinition.any_instance.stubs(:users).returns(import_definition_hash)
  end
  let(:imported_for) { stub }
  let(:imported_by) { stub }
  let(:import_definition_hash) { user_import_definition }

  let(:import_definition) { NfgCsvImporter::ImportDefinition.get_definition("users", imported_for, imported_by) }

  describe "#required_columns" do
    subject { import_definition.required_columns }
    context "when the definition's required_columns array contains only strings" do
      it "should return the array of strings" do
        expect(subject).to eq(required_columns)
      end
    end

    context "when the definition's required_columns array is nil" do
      let(:required_columns) { nil }
      it "should return an empty array" do
        expect(subject).to eq([])
      end
    end

  end

  describe "column_validation_rules" do
    subject { import_definition.column_validation_rules }
    context 'when the definitions column_validation_rules and required_columns are nil' do
      let(:column_validation_rules) { nil }
      let(:required_columns) { nil }
      it "should return an empty array" do
        expect(subject).to eq([])
      end
    end

    context "when the definition's column_validation_rules is an array of hashes" do
      context 'and all of the hashes contain the required keys' do
        it "should return an array of column validator objects" do
          expect(subject).to be_a(Array)
          expect(subject.first).to be_a(NfgCsvImporter::ColumnValidator)
        end
      end
    end

    context "and the required_columns is present" do
      let(:column_validation_rules) { [] }
      it "should include a rule for the required columns" do
        expect(subject.first.type).to eq("all")
        expect(subject.first.fields).to eq(["email", "first_name"])
      end
    end
  end

  describe "#can_be_viewed_by" do
    subject { import_definition.can_be_viewed_by(current_user) }
    let(:current_user) { stub(is_admin: is_admin) }
    let(:is_admin) { true }

    context "when the definition's can_be_viewed_by is nil" do
      it "should return true" do
        expect(subject).to be
      end
    end

    context "when the definition's can_be_viewed_by is set to a non-callable value" do
      let(:import_definition_hash) { user_import_definition.merge(can_be_viewed_by: value) }

      context "and the value is truthy" do
        let(:value) { "this is a string" }

        it "should be true" do
          expect(subject).to be
        end
      end

      context "when the value is falsey" do
        let(:value) { false }

        it "should be false" do
          expect(subject).not_to be
        end
      end
    end

    context "when the definition's can_be_viewed_by is set to a callable value" do
      let(:import_definition_hash) { user_import_definition.merge(can_be_viewed_by: -> (user) { user.is_admin }) }
      context "and the value returned by calling the function is false" do
        let(:is_admin) { false }

        it "should be false" do
          expect(subject).not_to be
        end
      end

      context "and the value returned by calling the function is true" do
        let(:is_admin) { true }

        it "should return true" do
          expect(subject).to be
        end
      end
    end
  end
end

def user_import_definition
  {
    required_columns: required_columns,
    column_validation_rules: column_validation_rules,
    optional_columns: %w{last_name},
    default_values: { "first_name" => lambda { |row| row["email"][/[^@]+/] } },
    class_name: "User",
    alias_attributes: [],
    column_descriptions: {},
    description: %Q{Allows you to import subscribers that then can receive daily, weekly, or newsletter emails. All of the columns listed above must be included in your file. Only the Email column is required to have a value. If first_name is blank, the system will set it to the text prior to the @ in the email.}
  }
end

def required_columns
  %w{ email first_name }
end

def column_validation_rules
  [{ type: "any", fields: ["first_name", "full_name"], message: "You must include either first_name or full_name" }]
end
