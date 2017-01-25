require 'rails_helper'

describe "imports/index.html.haml" do
  include Capybara::RSpecMatchers
  before do
    assign(:imports, imports)
    assign(:imported_for, entity)
    view.stubs(:current_user).returns(current_user)
  end
  let(:imports) { [] }
  let(:entity) { create(:entity) }
  let(:current_user) { stub("user") }

  subject { render template: 'nfg_csv_importer/imports/index' }

  context 'when there are no previous imports' do
    it "should display an empty content area that includes a unique data attribute" do
      expect(subject).to have_selector("[data-set-full-page='true']")
    end
  end

  context 'when the ImportDefinition.import_types is empty' do
    before do
      ImportDefinition.stubs(:import_types).returns([])
    end

    it "should not have any links to a new import" do
      expect(subject).not_to have_selector(".panel-heading a")
    end
  end

  context "when the ImportDefinition.import_types returns values" do
    before do
      ImportDefinition.stubs(:import_types).returns([:user, :donation])
      NfgCsvImporter::ImportDefinitionDetails.any_instance.expects(:can_be_viewed_by).with(current_user).returns(can_be_viewed_by).twice
    end

    context "when the import definition detail's can_be_viewed_by returns true" do
      let(:can_be_viewed_by) { true }

      it "should display a link to each of the types where no can_be_viewed_by entry is provided" do
        expect(subject).to have_selector(".card .card-block a[href$='/new?import_type=user']")
        expect(subject).to have_selector(".card .card-block a[href$='/new?import_type=donation']")
      end
    end

    context "when the import definition detail's can_be_viewed_by returns true" do
      let(:can_be_viewed_by) { false }

      it "should NOT display a link to each of the types where no can_be_viewed_by entry is provided" do
        expect(subject).not_to have_selector(".card .card-block a[href$='/new?import_type=user']")
        expect(subject).not_to have_selector(".card .card-block a[href$='/new?import_type=donation']")
      end
    end
  end
end
