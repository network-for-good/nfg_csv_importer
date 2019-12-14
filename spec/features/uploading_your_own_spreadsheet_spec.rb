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
    navigating_till_user_import_type

    and_by 'exiting' do
      click_link('Exit')
      sleep 10
    end

    page.go_back
    expect(page).to have_text I18n.t('nfg_csv_importer.onboarding.import_data.invalid_step_error')

    and_by 'clicking on edit while the import is still pending' do
      click_link ('Edit')
    end

    and_it 'takes you back to the current step' do
      expect(page).to have_content(I18n.t('nfg_csv_importer.onboarding.import_data.overview.header.page'))
    end

    import = NfgCsvImporter::Import.last

    navigating_from_overview_to_finish(import: import)

    and_by "finishing the import process by leaving the onboarder" do
      # finish
      expect(page).to have_text "You've finished this import"
      expect(page).to have_text "There were a total of 3 records"
      expect(page).to have_text "There were a total of 1 record with errors"

      click_next_button_for('finish')

      # back to the import list
      expect(page.current_path).to eq '/imports/'
    end

    and_by 'visiting the show page' do
      page.find("#import_#{import.id} [data-describe='import-details']").click
      expect(page).to have_css "[data-describe='import-show-page']"
    end

    and_it 'shows column mapping information' do
      expect(page).to have_css "[data-describe='column-mappings']"
    end
  end

  context 'when the import is marked as deleting' do
    it 'it takes the user to a new import state from the index page' do
      navigating_till_user_import_type
      import = NfgCsvImporter::Import.last
      navigating_from_overview_to_finish(import: import)

      and_by "finishing the import process by leaving the onboarder using direct page refresh" do
        # finish
        expect(page).to have_text "You've finished this import"
        visit nfg_csv_importer.imports_path

        # back to the import list
        expect(page.current_path).to eq '/imports/'
      end

      and_by 'deleting the import' do
        page.find("[data-describe='import_dropdown-#{import.id}']").click
        click_link I18n.t('nfg_csv_importer.imports.index.links.delete_import')
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content I18n.t('nfg_csv_importer.imports.index.status.deleted')
        expect(page).to have_content I18n.t('nfg_csv_importer.imports.index.buttons.begin')
        click_link I18n.t('nfg_csv_importer.imports.index.buttons.begin')
        and_it 'takes you back to file origination type selection page' do
          expect(page.current_path).to eq '/imports/onboarding/import_data/file_origination_type_selection'
        end
      end
    end
  end
end
