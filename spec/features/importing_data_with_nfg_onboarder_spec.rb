require 'rails_helper'



# shared_examples_for 'accessing the first step for importing a third-party pre-processed file' do |pre_processing_type:|
#   describe 'accessing the get started step' do
#     it 'takes the user to the get started step for the correct import pre-processing type' do
#       by 'visiting the imports index page' do
#         visit nfg_csv_importer.imports_path
#       end

#       and_by 'clicking the desired third party import type radio button' do
#         page.find("[data-describe='#{pre_processing_type}_pre_processing_type'] label").click
#       end

#       and_by 'clicking the submit button' do
#         click_button I18n.t('nfg_csv_importer.imports.index.buttons.begin')
#       end

#       and_by 'landing on the get started step' do
#         expect(page).to have_css "body.nfg_csv_importer-onboarding-import_data.get_started"
#       end

#       and_it 'communicates the correct pre processing third party type' do
#         expect(page).to have_text I18n.t("nfg_csv_importer.pre_processes.get_started_modal.pre_processing_type.step1.heading", pre_processing_type: pre_processing_type.humanize)

#         expect(page).to have_css "body.get_started.#{pre_processing_type}"
#       end
#     end
#   end
# end

describe "Using the nfg_onboarder engine to import data", js: true do
  let(:entity) { create(:entity) }
  let(:admin) {  create(:user) }

  describe 'picking a file origination type' do
    let(:file_origination_type) { 'mailchimp' }
    it 'accurately tracks the selected file origination type when on the :get_started step' do
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

#   describe 'importing a constant contact pre-processed file' do
#     it_behaves_like 'accessing the first step for importing a third-party pre-processed file', pre_processing_type: 'constant_contact'
#   end

#   describe 'importing a mailchimp pre-processed file' do
#     it_behaves_like 'accessing the first step for importing a third-party pre-processed file', pre_processing_type: 'mailchimp'
#   end

#   describe 'importing a paypal pre-processed file' do
#     it_behaves_like 'accessing the first step for importing a third-party pre-processed file', pre_processing_type: 'paypal'
#   end

#   describe 'importing a CSV processed file' do
#     it_behaves_like 'accessing the first step for importing a third-party pre-processed file', pre_processing_type: 'other'
#   end
end