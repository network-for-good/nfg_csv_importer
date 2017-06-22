require 'rails_helper'

describe "imports/index.html.haml" do
  include Capybara::RSpecMatchers
  before do
    assign(:imports, imports)
    assign(:imported_for, entity)
    view.extend NfgCsvImporter::ImportsHelper
    view.stubs(:current_user).returns(current_user)
  end
  let(:imports) { [] }
  let(:entity) { create(:entity) }
  let(:current_user) { stub("user") }

  subject { render template: 'nfg_csv_importer/imports/index' }

  context 'when the ImportDefinition.import_types is empty' do
    before do
      ImportDefinition.stubs(:import_types).returns([])
    end

    it "should not have any links to a new import" do
      expect(subject).not_to have_selector(".panel-heading a")
    end

    context 'when there are no previous imports' do
      it "should display an empty content area that includes a unique data attribute" do
        expect(subject).to have_selector("[data-set-full-page='true']")
      end
    end
  end

  context "when the ImportDefinition.import_types returns values" do
    before do
      ImportDefinition.stubs(:import_types).returns([:users, :donation])
      NfgCsvImporter::ImportDefinitionDetails.any_instance.expects(:can_be_viewed_by).with(current_user).returns(can_be_viewed_by).twice
    end

    context "when the import definition detail's can_be_viewed_by returns true" do
      let(:can_be_viewed_by) { true }

      it "should display a link to each of the types where no can_be_viewed_by entry is provided" do
        expect(subject).to have_selector(".card .card-block a[href$='/new?import_type=users']")
        expect(subject).to have_selector(".card .card-block a[href$='/new?import_type=donation']")
      end
    end

    context "when the import definition detail's can_be_viewed_by returns true" do
      let(:can_be_viewed_by) { false }

      it "should NOT display a link to each of the types where no can_be_viewed_by entry is provided" do
        expect(subject).not_to have_selector(".card .card-block a[href$='/new?import_type=users']")
        expect(subject).not_to have_selector(".card .card-block a[href$='/new?import_type=donation']")
      end
    end
  end

  context "when only one import definition can be viewed" do
    before do
      ImportDefinition.stubs(:import_types).returns([:users])
      NfgCsvImporter::ImportDefinitionDetails.any_instance.expects(:can_be_viewed_by).with(current_user).returns(true).once
    end

    it "should not display import_type_row" do
      expect(subject).not_to have_selector("#import_type_row")
    end

    it "start button should have link to first accessible import definition" do
      expect(subject).to have_link(I18n.t("links.start", scope: [:imports, :index]), href: NfgCsvImporter::Engine.routes.url_helpers.new_import_path(import_type: 'users'))
    end
  end

end
