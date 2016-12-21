require 'rails_helper'

describe "admin/imports/_import_fields.html.haml" do
  before do
    view.stubs(:imported_for).returns(entity)
    assign(:import, import)
  end

  subject { render :partial => 'nfg_csv_importer/imports/import_fields', :locals => { header: 'Test header', fields: fields } }

  let(:entity) { create(:entity) }
  let(:import) { FactoryGirl.build(:import, imported_for:entity)}
  let(:fields) { [] }

  context "when fields empty" do
    let(:fields) { [] }

    it "should not contain fieldset" do
      expect(subject).to eql("")
    end
  end

  context "when fields present" do
    let(:fields) { %w{cause_id name description}  }

    it "should display legend header" do
      expect(subject).to match('Test header')
    end

    it "should display fields" do
      fields.each do | field |
        expect(subject).to match(field)
      end
    end

    context "and description present for the field" do
      before { import.stubs(:column_descriptions).returns({ 'name' => 'Project name' } ) }

      it "should display field description" do
        subject
        expect(rendered).to match('- Project name')
      end
    end

  end
end