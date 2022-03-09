require 'rails_helper'

describe "Using the nfg_onboarder engine to upload files for NFG staff to import", js: true do
  let(:entity) { create(:entity) }
  let(:admin) {  create(:user) }
  let(:file_origination_type) { 'send_to_nfg' }

  it 'walks the user through selecting the files to upload file and eventually sends a message to NFG that they are ready for download' do

    by 'visiting the index page' do
      visit nfg_csv_importer.imports_path
    end

    and_by 'clicking the get started link' do
      page.find("[data-describe='import-data-onboarder-cta']").click
    end

    and_it 'takes the user to the onboarder at the first step - file origination type selection' do
      expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.file_origination_type_selection"
    end

    and_by 'selecting a file origination type' do
      page.find("label[for='nfg_csv_importer_onboarding_import_data_file_origination_type_selection_file_origination_type_#{file_origination_type}']").click
    end

    and_by 'submitting the form / clicking the `next` button' do
      click_button 'Next'
    end

    and_it 'takes the user to the upload_preprocessing step' do
      expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.upload_preprocessing.#{file_origination_type}"
    end

    and_by 'attaching a couple files to the dropzone file field' do
      drop_in_dropzone(File.expand_path("spec/fixtures/users_for_full_import_spec.xls"))
      sleep 2
      drop_in_dropzone(File.expand_path("spec/fixtures/subscribers.csv"))
      sleep 2
      page.all("div.progress-bar[style='width: 100%;']", count: 2, wait: 10) # the first progress bar
      fill_in I18n.t('labels.note', scope: [:nfg_csv_importer, :onboarding, :import_data, :upload_preprocessing]), with: "The are great files"
      expect { click_button 'Next' }.to change(NfgCsvImporter::Import, :count).by(1)
    end

    and_it 'takes the user to the finish page' do
      expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.finish"
    end

    and_by 'clicking the next button, takes the user to the imports_path' do
      click_button I18n.t("nfg_csv_importer.onboarding.import_data.title_bar.buttons.exit")
      expect(current_path).to eq(nfg_csv_importer.imports_path)
    end
  end
end
