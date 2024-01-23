require 'rails_helper'
require 'sidekiq/testing'

describe "Importing your own spreadsheet", js: true do
  let(:file_origination_type) { 'self_import_csv_xls' }

  let(:site) { create(:entity) }
  let!(:admin) { create(:user ) }

  let(:path_to_file) { File.expand_path('spec/fixtures/subscribers.csv') }
  let(:path_to_new_file) { File.expand_path('spec/fixtures/subscribers_copy.csv') }
  let(:expected_user_count) { 2 }

  before do
    visit nfg_csv_importer.imports_path
  end

  shared_examples_for 'completing an import' do
    it 'Walks the admin through uploading/mapping/importing their own spreadsheet' do
      navigating_till_user_import_type

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

      navigating_from_overview_to_finish(import: import, expected_user_count: expected_user_count)

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
  end

  it_behaves_like 'completing an import'

  context 'when file is re-uploaded and file name changes' do
    let(:expected_user_count) { 3 } # new file has all valid records

    it 'Walks the admin through uploading/mapping/importing their own spreadsheet' do
      navigating_till_user_import_type
      expect(page).to have_content(I18n.t('nfg_csv_importer.onboarding.import_data.overview.header.page'))

      import = NfgCsvImporter::Import.last

      navigating_from_overview_to_finish(import: import, expected_user_count: expected_user_count) do
        and_by 'clicking the previous button' do
          click_link "Prev"
        end

        and_by 'selecting a new file' do
          # upload_post_processing
          attach_file 'nfg_csv_importer_onboarding_import_data_upload_post_processing_import_file', path_to_new_file, visible: false
          click_next_button_for('upload_post_processing')
        end
      end

      and_by "finishing the import process by leaving the onboarder" do
        # finish
        expect(page).to have_text "You've finished this import"
        click_next_button_for('finish')
        # back to the import list
        expect(page.current_path).to eq '/imports/'
      end

      and_by 'visiting the show page' do
        page.find("#import_#{import.id} [data-describe='import-details']").click
      end

      and_it 'shows the correct file name' do
        within "[data-describe='user-generated-import-file']" do
          expect(page).to have_content File.basename(path_to_new_file)
        end
      end
    end
  end

  context 'when the import is marked as deleting' do
    it 'it takes the user to a new import state from the index page' do
      navigating_till_user_import_type
      import = NfgCsvImporter::Import.last
      navigating_from_overview_to_finish(import: import, expected_user_count: expected_user_count)

      and_by "finishing the import process by leaving the onboarder using direct page refresh" do
        # finish
        expect(page).to have_text "You've finished this import"
        visit nfg_csv_importer.imports_path

        # back to the import list
        expect(page.current_path).to eq '/imports/'
      end

      and_by 'deleting the import' do
        within "[data-describe='import_dropdown-#{import.id}']" do
          find('.dropdown-toggle').click
        end
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

  context 'when the file has more rows than allowed' do
    before do
      NfgCsvImporter.configuration.max_number_of_rows_allowed = 2
      NfgCsvImporter.configuration.allowed_file_origination_types_to_bypass_max_row_limit = []
    end

    after do
      NfgCsvImporter.configuration.max_number_of_rows_allowed = 20_000
      NfgCsvImporter.configuration.allowed_file_origination_types_to_bypass_max_row_limit = []
    end

    context 'when the admin does not have permissions to bypass max row limit' do
      it 'Walks the admin through uploading/mapping/importing their own spreadsheet' do
        navigating_till_user_import_type

        and_by 'reviewing the import overview page' do
          click_next_button_for('overview')
        end

        and_by 'uploading the post procesing import files' do
          # upload_post_processing
          attach_file 'nfg_csv_importer_onboarding_import_data_upload_post_processing_import_file', path_to_file, visible: false
          click_next_button_for('upload_post_processing')
        end

        and_it 'should list the max number of rows allowed error' do
          expect(page).to have_content I18n.t('nfg_csv_importer.onboarding.import_data.invalid_number_of_rows',
                                              num_rows: NfgCsvImporter.configuration.max_number_of_rows_allowed)
        end
      end
    end

    context 'when the admin has permissions to bypass max row limit' do
      # in test_app import_defnition, admin with 'Jones' as last name is not allowed to bypass limit
      let!(:admin) { create(:user, last_name: 'Jones') }

      it_behaves_like 'completing an import'
    end
  end
end
