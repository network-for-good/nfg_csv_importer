require "rails_helper"

RSpec.describe "onboarding/import_data/import_type.html.haml", type: :view do
  before do
    stub_template "onboarding/import_data/import_type.html.haml" => "= ui.nfg(title: @title)"
    view.stubs(:f).returns(stub("FormBuilder", radio_button: true))
    @mock_ui = mock("UIHelper")
    view.stubs(:ui).returns(@mock_ui)
  end

  context "when definition.import_title is nil" do
    let(:import_type) { "example_import_type" }
    let(:definition) { OpenStruct.new(import_title: nil, headline: "Example Headline") }

    before do
      view.stubs(:import_definitions).returns({ example_import_type: definition })
      @title = import_type.to_s.pluralize.titleize
      assign(:title, @title)
    end

    it "calls ui.nfg with the title as the pluralized and titleized import_type" do
      expect(@mock_ui).to receive(:nfg).with(has_entry(title: "Example Import Types"))
      render
    end
  end

  context "when definition.import_title has a value" do
    let(:import_title) { "Custom Import Title" }
    let(:definition) { OpenStruct.new(import_title: import_title, headline: "Example Headline") }

    before do
      view.stubs(:import_definitions).returns({ example_import_type: definition })
      @title = import_title
      assign(:title, @title)
    end

    it "calls ui.nfg with the title as definition.import_title" do
      expect(@mock_ui).to receive(:nfg).with(has_entry(title: "Custom Import Title"))
      render
    end
  end
end
