require 'rails_helper'

RSpec.describe 'onboarding/import_data/preview_confirmation/data_preview_card_default.html.haml' do
  before do
    # no need render the full sub layout (and all of its dependencies)
    # since that should be tested elsewhere. We just need it to
    # yield the block that is passed into it
    view.stubs(:details).returns(details)
  end
  let(:details) { %w[val, another_val] }

  subject { render template: 'nfg_csv_importer/onboarding/import_data/preview_confirmation/_data_preview_card_default' }

  it 'should have the right buttons' do
    subject
    expect(rendered).to have_content 'val'
    expect(rendered).to have_content 'another_val'
  end
end
