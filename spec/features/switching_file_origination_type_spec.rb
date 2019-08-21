require 'rails_helper'

describe "switching file origination types", js: true do
  let(:entity) { create(:entity) }
  let(:admin) {  create(:user) }
  let(:file_origination_type) { 'paypal' }

  it 'walks the user through selecting the paypal file' do
    visiting_till_the_preview_confirmation_page

    page.find("[data-describe='file_origination_type_selection-step']").click
    puts 1
    and_by 'selecting send_to_nfg file origination type' do
      page.find("label[for='nfg_csv_importer_onboarding_import_data_file_origination_type_selection_file_origination_type_send_to_nfg']").click
    end
    click_button 'Next'
    expect(page).to_not have_content 'paypal_sample_file.xlsx'
  end
end
