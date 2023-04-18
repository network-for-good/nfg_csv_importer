require 'rails_helper'

describe "Using the nfg_onboarder engine to import paypal transactions", js: true do
  let!(:entity) { create(:entity) }
  let!(:admin) {  create(:user, entity: entity) }
  let(:file_origination_type) { 'paypal' }

  it 'walks the user through selecting the paypal file and eventually imports the donors/donations in the file' do
    visiting_till_the_preview_confirmation_page

    and_it 'should not have invalid header message anymore' do
      expect(page).to_not have_content Roo::HeaderRowNotFoundError.new.message
    end

    and_it 'does not show the column mapping conversion table' do
      expect(page).not_to have_css "[data-describe='column-mappings']"
    end

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

    and_by 'returning to the imports index page' do
      page.find("[data-describe='view-all']").click
      expect(page).to have_css "#imports_listing"
    end

    and_by 'browsing to the imports show page' do
      page.find("#import_#{@import.id} [data-describe='import-details']", text: 'Details').click
      expect(page).to have_css "[data-describe='import-show-page']"
    end

    and_it 'does not show the column header mapping' do
      expect(page).not_to have_css "[data-describe='column-mappings']"
    end
  end

  it 'shows the invalid file type error' do
    visiting_till_the_upload_preprocessing_page

    and_by 'attaching the a wrong extensions file to the dropzone file field' do
      drop_in_dropzone(File.expand_path("spec/fixtures/text_file.txt"))
      page.find("div.progress-bar[style='width: 100%;']", wait: 10)
      click_button 'Next' # the import was created on the invalid step above
      @import = NfgCsvImporter::Import.last
    end

    and_it 'shows the error message' do
      expect(page).to have_content "Pre processing files The file must be of csv,xls,xlsx format"
    end
  end

  it 'leaves the onboarder flow and then clicks on edit on index page to land back at the last step' do
    visiting_till_the_preview_confirmation_page
    and_by 'visiting the imports index page' do
      click_link "Exit"
    end

    and_by 'clicking the edit button' do
      click_link "Edit"
    end

    and_it 'takes the user back to the preview confirmation page' do
      expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.preview_confirmation"
    end
  end

  it 'allows to navigate back from preview' do
    visiting_till_the_preview_confirmation_page

    and_by 'clicking the previous button' do
      click_link "Prev"
    end

    and_by 'clicking the next button' do
      click_button "Next"
    end

    and_it 'takes the user back to the preview confirmation page' do
      expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.preview_confirmation"
    end
  end

  it 'allows navigation to imports show page from the finish step' do
    visiting_till_the_history_page

    and_by 'clicking on the import details button' do
      click_button I18n.t('nfg_csv_importer.onboarding.import_data.finish.button.details')
    end

    and_it 'takes the user back to the imports show page' do
      expect(page).to have_content I18n.t('nfg_csv_importer.imports.show.imported_by')
    end
  end

  context 'when creating two simultaneous imports' do
    it 'succesfully shifts to the right import when editing' do
      visiting_till_the_preview_confirmation_page

      and_by 'visiting the imports index page' do
        click_link "Exit"
      end

      and_by 'opening a new tab and switching to it' do
        open_new_window
        switch_to_window windows.last
      end

      and_by 'starting a new import on the new tab' do
        visiting_till_the_file_origination_type_selection_page
      end

      and_by 'switching to the first tab with index page again' do
        switch_to_window windows.first
      end

      and_by 'clicking the edit button of the first import' do
        click_link "Edit"
      end

      and_it 'takes the user to the preview_confirmation page' do
        expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.preview_confirmation"
      end
    end
  end
end
