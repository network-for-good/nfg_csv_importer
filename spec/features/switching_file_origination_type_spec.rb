require 'rails_helper'

describe "switching file origination types", js: true do
  let(:entity) { create(:entity) }
  let(:admin) {  create(:user) }
  let(:file_origination_type) { 'paypal' }

  it 'walks the user through selecting the paypal file' do
    visiting_till_the_preview_confirmation_page

    # currently we don't allow file origination type change after a note has been added
    # this is a hack to test clearing of the note
    and_by "adding a note to the session" do
      step_data = @import.onboarding_session.step_data
      step_data['import_data'][:upload_preprocessing]['note'] = 'some-note'
      @import.onboarding_session.update_attributes!(step_data: step_data)
    end

    page.find("[data-describe='file_origination_type_selection-step']").click
    and_by 'selecting send_to_nfg file origination type' do
      page.find("label[for='nfg_csv_importer_onboarding_import_data_file_origination_type_selection_file_origination_type_send_to_nfg']").click
    end
    click_button 'Next'
    expect(page).to_not have_content 'paypal_sample_file.xlsx'
    expect(@import.onboarding_session.reload.step_data['import_data'][:upload_preprocessing]['note']).to be_nil
  end
end
