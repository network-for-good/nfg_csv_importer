require 'rails_helper'

describe "Using the nfg_onboarder engine to import paypal transactions", js: true do
  let(:entity) { create(:entity) }
  let(:admin) {  create(:user) }
  let(:file_origination_type) { 'paypal' }
  let(:valid_filename) { 'paypal_sample_file.xlsx' }
  let(:invalid_filename) { 'icon.jpg' }

  it 'walks the user through selecting the paypal file and eventually imports the donors/donations in the file' do

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

    and_it 'defaults to the empty state dropzone interface' do
      expect(page).to have_selector '.dropzone-target', text: 'Drag and drop your'

      and_it 'does not have the activated css classes enabled' do
        # expect(page).not_to have_css '.dz-started.dz-drag-hover'
      end
    end

    and_context 'when attaching an invalid file' do
      and_it 'does not pre-load an error state' do
        expect(page).not_to have_css "[data-dz-errormessage]"
        expect(page).not_to have_css '.dz-error-mark .fa-times'
      end

      by 'dropping an image file' do
        drop_in_dropzone(File.expand_path("spec/fixtures/icon.jpg"))
      end

      # These css classes are specifically removed during the resetUI function.
      and_it 'activates the dropzone' do
        # expect(page).to have_css '.dz-started.dz-drag-hover'
      end

      and_it 'renders the progress bar' do
        verify_progress_bar_completion(invalid_filename)
      end

      and_it 'puts the dropzone file field in an error state' do
        expect(page).to have_css '.dz-error.dz-complete'
      end

      and_it 'provides an error message' do
        expect(page).to have_selector "[data-dz-errormessage]", text: "You can't upload files of this type"
      end

      and_it 'shows the error icon' do
        expect(page).to have_css '.dz-error-mark .fa-times'
      end

      and_it 'does not show the success icon' do
        expect(page).not_to have_css '.dz-success-mark .fa-check'
      end

      and_it 'is removable from the dropzone interface' do
        click_link 'Remove file'
      end

      and_it 'removes the file from the interface' do
        expect(page).not_to have_css "[data-describe='progress-bar-for-#{invalid_filename}']"
      end

      and_it 'returns to the standard presentation once the file is removed' do
        # expect(page).not_to have_css '.dz-started.dz-drag-hover'
        expect(page).to have_selector '.dropzone-target', text: 'Drag and drop your'
      end
    end

    and_by 'attaching the a paypal file to the dropzone file field' do
      drop_in_dropzone(File.expand_path("spec/fixtures/paypal_sample_file.xlsx"))
      verify_progress_bar_completion(valid_filename)
    end
  end
end

def verify_progress_bar_completion(filename)
  expect(page.find("[data-describe='progress-bar-for-#{filename}'].progress-bar[style='width: 100%;']")).to be
end
