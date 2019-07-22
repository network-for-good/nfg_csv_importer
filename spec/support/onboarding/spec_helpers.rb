def visiting_till_the_preview_confirmation_page
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

  and_by 'attaching an invalid paypal file to the dropzone file field' do
    drop_in_dropzone(File.expand_path("spec/fixtures/files/invalid_import.csv"))
    page.find("div.progress-bar[style='width: 100%;']", wait: 10)
    click_button "Next"
  end

  and_it 'prevents the user from continuing to the next step' do
    expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.upload_preprocessing"
  end

  and_it 'shows the error message' do
    expect(page).to have_content Roo::HeaderRowNotFoundError.new.message
  end

  and_by 'attaching the a paypal file to the dropzone file field' do
    drop_in_dropzone(File.expand_path("spec/fixtures/paypal_sample_file.xlsx"))
    sleep 5
    page.find("div.progress-bar[style='width: 100%;']", wait: 10)
    expect { click_button 'Next' }.to change(NfgCsvImporter::Import, :count).by(1)
    @import = NfgCsvImporter::Import.last
  end

  and_it 'takes the user to the preview_confirmation page' do
    expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.preview_confirmation"
  end
end
