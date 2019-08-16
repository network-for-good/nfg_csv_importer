require 'rails_helper'

describe "Importing your own spreadsheet", js: true do
  let(:file_origination_type) { 'self_import_csv_xls' }

  let(:site) { create(:entity) }
  let(:admin) { create(:user) }

  let(:path_to_file) { File.expand_path('spec/fixtures/subscribers.csv') }

  before do
    visit nfg_csv_importer.imports_path
  end

  it 'Walks the admin through uploading/mapping/importing their own spreadsheet' do
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

    and_by 'exiting' do
      click_link('Exit')
    end

    and_by 'clicking on edit while the import is still pending' do
      click_link ('Edit')
    end

    and_it 'takes you back to the current step' do
      expect(page).to have_content(I18n.t('nfg_csv_importer.onboarding.import_data.overview.header.page'))
    end

    import = NfgCsvImporter::Import.last

    and_by 'reviewing the import overview page' do
      click_next_button_for('overview')
    end

    and_by 'uploading the post procesing import files' do
      # upload_post_processing
      attach_file 'nfg_csv_importer_onboarding_import_data_upload_post_processing_import_file', path_to_file, visible: false
      click_next_button_for('upload_post_processing')
    end

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
      end.to change(User, :count).by(2)

      # and_it 'shows the column mapping conversion table' do
      #   expect(page).to have_css "[data-describe='column-mappings']"
      # end
    end

    and_by "finishing the import process by leaving the onboarder" do
      # finish
      expect(page).to have_text "You've finished this import"
      expect(page).to have_text "There were a total of 3 records"
      expect(page).to have_text "There were a total of 1 record with errors"

      click_next_button_for('finish')

      # back to the import list
      expect(page.current_path).to eq '/nfg_csv_importer/'
    end

    and_by 'visiting the show page' do
      page.find("#import_#{import.id} [data-describe='import-details']").click
      expect(page).to have_css "[data-describe='import-show-page']"
    end

    and_it 'shows column mapping information' do
      expect(page).to have_css "[data-describe='column-mappings']"
    end
  end
end
