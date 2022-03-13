require 'rails_helper'

RSpec.describe 'onboarding/import_data/preview_confirmation/data_preview_card_user.html.haml' do
  before do
    # no need render the full sub layout (and all of its dependencies)
    # since that should be tested elsewhere. We just need it to
    # yield the block that is passed into it
    view.stubs(:details).returns(details)
  end
  let(:name) { 'some name' }
  let(:email) { 'some email' }
  let(:phone) { '5408783333' }
  let(:address) { '343 some st.'}
  let(:address_2) { '#202' }
  let(:city) { 'some city' }
  let(:details) do
    { "full_name" => name, "email" => email, "home_phone" => phone, "address" => address, "address_2" => address_2, "city" => city }
  end

  subject { render template: 'nfg_csv_importer/onboarding/import_data/preview_confirmation/_data_preview_card_user' }

  it 'should have the right buttons' do
    subject
    expect(rendered).to have_content name
    expect(rendered).to have_content email
    expect(rendered).to have_content phone
    expect(rendered).to have_content address
    expect(rendered).to have_content address_2
    expect(rendered).to have_content city
  end
end
