require 'rails_helper'

RSpec.describe 'onboarding/import_data/preview_confirmation/default_summary_data.html.haml' do
  before do
    import.expects(:statistics_and_examples).returns(details)
    view.stubs(:import).returns(import)
    stub_template "nfg_csv_importer/onboarding/import_data/preview_confirmation/_data_preview_card_default.html.haml" => "<p></p>"
    view.stubs(:i18n_scope).returns([:nfg_csv_importer, :onboarding, :import_data, step])
  end

  let(:template) { 'nfg_csv_importer/onboarding/import_data/preview_confirmation/_default_summary_data' }
  let(:step) { 'preview_confirmation' }
  let(:import) { mock('import') }
  let(:num_rows) { 11 }
  let(:val) { 'some-value' }
  let(:another_val) { 'another-value' }
  let(:details) do
    {
      "summary_data" => { "number_of_rows" => num_rows },
      "example_rows" => [val, another_val]
    }
  end

  subject { render template: template }

  it 'should have the number of rows' do
    subject
    expect(rendered).to have_content num_rows
  end

  it 'should render the data_preview_card_default template' do
    expect(subject).to render_template template, { details: val }
    expect(subject).to render_template template, { details: another_val }
  end

  context 'when example rows are nil' do
    let(:details) do
      {
        "summary_data" => { "number_of_rows" => num_rows }
      }
    end

    it 'should not render the data preview card default template' do
      expect(subject).to render_template template, { details: nil }
    end
  end
end
