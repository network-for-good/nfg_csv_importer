require 'rails_helper'

describe "Using the nfg_onboarder engine to import paypal transactions", js: true do
  let(:entity) { create(:entity) }
  let(:admin) {  create(:user) }
  let(:file_origination_type) { 'paypal' }

  it 'walks the user through selecting the paypal file and eventually imports the donors/donations in the file' do
    visiting_till_the_preview_confirmation_page

    and_it 'should not have invalid header message anymore' do
      expect(page).to_not have_content Roo::HeaderRowNotFoundError.new.message
    end

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
end
