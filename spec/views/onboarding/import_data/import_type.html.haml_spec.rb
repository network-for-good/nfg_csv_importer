require "rails_helper"

RSpec.describe "onboarding/import_data/import_type.html.haml", type: :view do
  before do
    engine_root = NfgCsvImporter::Engine.root
    view.lookup_context.view_paths.push(engine_root.join('app', 'views'))
    view.stubs(:f).returns(stub("FormBuilder", radio_button: ''))
    view.stubs(:t).returns('')  # Stub translation helper
    view.stubs(:onboarder_presenter).returns(stub('Presenter', render_google_tag_manager: ''))
    view.stubs(:ui).returns(stub('UIHelper', nfg: '<nfg output>'))
  end

  context "when definition.import_title is nil" do
    let(:import_type) { "example_import_type" }
    let(:definition) { OpenStruct.new(import_title: nil, headline: "Example Headline") }

    before do
      assign(:import_definitions, { import_type => definition })
    end

    it "displays the pluralized and titleized import_type as the title" do
      render
      expect(rendered).to include("Example Import Types")
    end
  end

  context "when definition.import_title has a value" do
    let(:import_type) { "example_import_type" }
    let(:import_title) { "Custom Import Title" }
    let(:definition) { OpenStruct.new(import_title: import_title, headline: "Example Headline") }

    before do
      assign(:import_definitions, { import_type => definition })
    end

    it "displays definition.import_title as the title" do
      render
      expect(rendered).to include("Custom Import Title")
    end
  end
end
