require "rails_helper"

RSpec.describe "onboarding/import_data/import_type.html.haml", type: :view do
  before do
    stub_template "nfg_csv_importer/onboarding/_sub_layout.html.haml" => "= yield"
    view.stubs(:f).returns(stub("FormBuilder", radio_button: true))
    view.stubs(:ui).returns(stub("UIHelper", nfg: nil))
  end

  context "when definition.import_title is nil" do
    let(:import_type) { "example_import_type" }
    let(:definition) { OpenStruct.new(import_title: nil, headline: "Example Headline") }

    before do
      view.stubs(:import_definitions).returns({ example_import_type: definition })
    end

    it "calls ui.nfg with the title as the pluralized and titleized import_type" do
      view.ui.expects(:nfg).with(has_entry(title: import_type.to_s.pluralize.titleize))
      render
    end
  end

  context "when definition.import_title has a value" do
    let(:import_title) { "Custom Import Title" }
    let(:definition) { OpenStruct.new(import_title: import_title, headline: "Example Headline") }

    before do
      view.stubs(:import_definitions).returns({ example_import_type: definition })
    end

    it "calls ui.nfg with the title as definition.import_title" do
      view.ui.expects(:nfg).with(has_entry(title: import_title))
      render
    end
  end
end
