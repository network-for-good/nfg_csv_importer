require 'rails_helper'

describe "switching file origination types", js: true do
  let(:entity) { create(:entity) }
  let(:admin) {  create(:user) }
  let(:file_origination_type) { 'paypal' }

  shared_examples_for 'successfully transitioning from one file origination type to another' do |new_fot|
    it 'walks the user through selecting the paypal file' do
      visiting_till_the_preview_confirmation_page

      # currently we don't allow file origination type change after a note has been added
      # this is a hack to test clearing of the note
      and_by "adding a note to the session" do
        step_data = @import.onboarding_session.step_data
        step_data['import_data'][:upload_preprocessing]['note'] = 'some-note'
        @import.onboarding_session.update(step_data: step_data)
      end

      page.find("[data-describe='file_origination_type_selection-step']").click
      and_by 'selecting send_to_nfg file origination type' do
        page.find("label[for='nfg_csv_importer_onboarding_import_data_file_origination_type_selection_file_origination_type_#{new_fot}']").click
      end
      click_button 'Next'
      expect(page).to_not have_content 'paypal_sample_file.xlsx'
      if new_fot == NfgCsvImporter::FileOriginationTypes::Manager::DEFAULT_FILE_ORIGINATION_TYPE_SYM.to_s
        expect(page).to have_content I18n.t('nfg_csv_importer.onboarding.import_data.import_type.header.message')
      else
        expect(page).to have_content I18n.t("nfg_csv_importer.onboarding.import_data.upload_preprocessing.header.file_origination_type.message.#{new_fot}")
      end

      expect(@import.onboarding_session.reload.step_data['import_data'][:upload_preprocessing]['note']).to be_nil
    end
  end

  context 'when switching from paypal to send_to_nfg' do
    it_behaves_like 'successfully transitioning from one file origination type to another', 'send_to_nfg'
  end

  context 'when switching from paypal to your own spreadsheet' do
    it_behaves_like 'successfully transitioning from one file origination type to another', 'self_import_csv_xls'
  end

end
