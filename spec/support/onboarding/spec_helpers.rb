def visiting_till_the_preview_confirmation_page
  visiting_till_the_upload_preprocessing_page

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

def visiting_till_the_upload_preprocessing_page
  visiting_till_the_file_origination_type_selection_page

  and_by 'selecting a file origination type' do
    page.find("label[for='nfg_csv_importer_onboarding_import_data_file_origination_type_selection_file_origination_type_#{file_origination_type}']").click
  end

  and_by 'submitting the form / clicking the `next` button' do
    click_button 'Next'
  end

  and_it 'takes the user to the upload_preprocessing step' do
    expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.upload_preprocessing.#{file_origination_type}"
  end
end

def visiting_till_the_file_origination_type_selection_page
  by 'visiting the index page' do
    visit nfg_csv_importer.imports_path
  end

  and_by 'clicking the get started link' do
    page.find("[data-describe='import-data-onboarder-cta']").click
  end

  and_it 'takes the user to the onboarder at the first step - file origination type selection' do
    expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.file_origination_type_selection"
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
    }.to change { @import.reload.status }.from(NfgCsvImporter::Import::CALCULATING_STATISTICS_STATUS.to_s)
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

def navigating_till_user_import_type
  by 'initiating an import' do
    visit nfg_csv_importer.imports_path
    page.find("[data-describe='import-data-onboarder-cta']").click
  end

  and_by 'selecting the "import your own" file origination type' do
    # file_origination_type_selection
    page.find("label[for='nfg_csv_importer_onboarding_import_data_file_origination_type_selection_file_origination_type_self_import_csv_xls']").click
    click_next_button_for('file_origination_type_selection')
  end


  and_by 'selecting the user import type' do
    # import type page (visible since there are more than one import type available for this user)
    page.find("label[for='nfg_csv_importer_onboarding_import_data_import_type_import_type_users']").click

    # we save the import record when the user selects the import type
    expect do
      click_next_button_for('import_type')
    end.to change(NfgCsvImporter::Import, :count).by(1)
  end
end

def navigating_from_overview_to_finish(import:, expected_user_count:)
  and_by 'reviewing the import overview page' do
    click_next_button_for('overview')
  end

  and_by 'uploading the post procesing import files' do
    # upload_post_processing
    attach_file 'nfg_csv_importer_onboarding_import_data_upload_post_processing_import_file', path_to_file, visible: false
    click_next_button_for('upload_post_processing')
  end

  yield if block_given? # for going back and selecting a new file

  and_by 'mapping the fields' do
    # field_mapping
    within_frame('edit_import_iframe') do
      within 'div[data-column-name="last_name"]' do
        click_link 'Edit Column'
      end
      expect(page).to have_text "Not ready to import"
    end

    expect(page).to have_button(next_button_label('field_mapping'), disabled: true)
    within_frame('edit_import_iframe') do
      within('#card_header_last_name') do
        select 'Last Name', from: 'import_fields_mapping_bGFzdF9uYW1l_'
      end
      expect(page).to have_text "Ready to import"
    end
    click_button 'Next'
  end

  and_by 'reviewing the details and summary of the file and submitting the import' do
    # preview_confirmation
    expect(page).to have_content("TOTAL ROWS 3")

    expect do
      click_next_button_for('preview_confirmation')
      page.driver.browser.switch_to.alert.accept

      # We now should be headed to the finish page
      # but let's wait here until the import completes
      while import.reload.status != 'complete' do
        # the import is running, we just need to wait until it completes
        sleep 0.05
      end
    end.to change(User, :count).by(expected_user_count)

    # and_it 'shows the column mapping conversion table' do
    #   expect(page).to have_css "[data-describe='column-mappings']"
    # end
  end
end
