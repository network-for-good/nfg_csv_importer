require 'rails_helper'

describe "Using the nfg_onboarder engine to import data", js: true do
  let(:entity) { create(:entity) }
  let(:admin) {  create(:user) }

  describe 'picking a file origination type' do
    let(:file_origination_type) { 'mailchimp' }
    it 'accurately tracks the selected file origination type once the file origination type has been selected and submitted' do

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

      and_it 'takes the user to the next step' do
        expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.get_started.#{file_origination_type}"
      end

      and_it 'indicates the user is reading information about the correct file origination type' do
        expect(page).to have_selector "[data-toggle='tour-slider']", text: file_origination_type.humanize
      end
    end
  end
end