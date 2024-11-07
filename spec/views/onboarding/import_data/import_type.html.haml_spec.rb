require "rails_helper"

RSpec.describe "onboarding/import_data/import_type.html.haml", type: :view do
  before do
    stub_template "nfg_csv_importer/onboarding/_sub_layout.html.haml" => "= yield"
    allow(view).to receive(:f).and_return(double("FormBuilder", radio_button: true))
    allow(view).to receive(:ui).and_return(double("UIHelper", nfg: nil))
  end

  context "when definition.import_title is nil" do
    let(:import_type) { "example_import_type" }
    let(:definition) { OpenStruct.new(import_title: nil, headline: "Example Headline") }

    before do
      allow(view).to receive(:import_definitions).and_return({ example_import_type: definition })
    end

    it "calls ui.nfg with the title as the pluralized and titleized import_type" do
      render
      expect(view.ui).to have_received(:nfg).with(hash_including(title: import_type.to_s.pluralize.titleize))
    end
  end

  context "when definition.import_title has a value" do
    let(:import_title) { "Custom Import Title" }
    let(:definition) { OpenStruct.new(import_title: import_title, headline: "Example Headline") }

    before do
      allow(view).to receive(:import_definitions).and_return({ example_import_type: definition })
    end

    it "calls ui.nfg with the title as definition.import_title" do
      render
      expect(view.ui).to have_received(:nfg).with(hash_including(title: import_title))
    end
  end
end
