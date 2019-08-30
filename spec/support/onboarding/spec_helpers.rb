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
    expect(page).to have_content "The file is not formatted correctly"
  end

  and_by 'removing the invalid data' do
    click_link "Remove file"
    sleep 2
  end

  and_by 'attaching the a paypal file to the dropzone file field' do
    drop_in_dropzone(File.expand_path("spec/fixtures/paypal_sample_file.xlsx"))
    page.find("div.progress-bar[style='width: 100%;']", wait: 10)
    click_button 'Next' # the import was created on the invalid step above
    @import = NfgCsvImporter::Import.last
  end

  and_it 'takes the user to the preview_confirmation page' do
    expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.preview_confirmation"
  end
end

def visiting_till_the_history_page
  visiting_till_the_preview_confirmation_page

  and_by 'confirming the preview confirmation page it should kick off the import' do
    expect {
      click_button  I18n.t("nfg_csv_importer.onboarding.import_data.preview_confirmation.button.approve")
      page.driver.browser.switch_to.alert.accept
      # we wait until the finish page displays
      page.find("body.nfg_csv_importer-onboarding-import_data.finish.#{file_origination_type}", wait: 5)
    }.to change { @import.reload.status }.from("uploaded")
  end

  and_by 'waiting until the import completes' do
    # this is a bit hacky, but i wanted to make sure
    # the import was finished before testing
    # for some proof that it was successful
    # on the page.
    # In reality, we may want to assume that the
    # job has been queued and not provide any
    # indication that this page could display
    # some results from the import, but instead
    # note that the job has been enqueued and perhaps
    # let the user know how many other jobs are in
    # from of it
    until @import.reload.complete? do
      # wait until the import has completed
      sleep 0.5
    end
    # reload the page once the import has completed
    page.evaluate_script 'window.location.reload()'

    # since the import has already completed (which will unlikely be the case in production)
    # we show how many records were added
    # In production, we will likely have different messages depending on the status of the import
    expect(page).to have_content "You've finished this import! There were a total of 4 records"
  end
end
