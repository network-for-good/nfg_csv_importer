require "rails_helper"

RSpec.describe "nfg_csv_importer/onboarding/import_data/import_type.html.haml", type: :view do
  before do
    stub_template "nfg_csv_importer/onboarding/_sub_layout.html.haml" => fake_form

    view.stubs(:onboarder_presenter).returns(stub('Presenter', render_google_tag_manager: ''))
    view.stubs(:import_definitions).returns({ import_type => definition } )
    render
  end

  let(:import_type) { "example_import_type" }
  let(:fake_form) do
    # the sublayout needs to supply a form that is passed
    # to its children. The text block below returns
    # a fake version of the the sublayout which requires
    # a lot more setup than is healthy for a simple view
    # spec. So we return this fake form below which
    # mimics what the real sub_layout does, but without
    # all of the overhead
    %Q{
- import = NfgCsvImporter::Import.new
- form = NfgCsvImporter::Onboarding::ImportData::ImportTypeForm.new(import)
= form_for(form, url: '/path') do |f|
  = yield f
  }
  end

  context "when definition.import_title is nil" do
    let(:definition) { OpenStruct.new(import_title: nil, headline: "Example Headline") }

    it "displays the pluralized and titleized import_type as the title" do
      expect(rendered).to include(import_type.pluralize.titleize)
    end
  end

  context "when definition.import_title has a value" do
    let(:definition) { OpenStruct.new(import_title: "Custom Import Title", headline: "Example Headline") }

    it "displays definition.import_title as the title" do
      expect(rendered).to include(definition.import_title)
    end
  end
end