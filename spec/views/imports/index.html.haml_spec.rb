require 'rails_helper'
# require 'will_paginate' # so that tests can use will_paginate methods
# require 'will_paginate/array'

RSpec.describe "nfg_csv_importer/imports/index.html.haml", type: :view do
  let(:current_user) { FactoryGirl.create(:user) }
  let(:import) { FactoryGirl.create(:import, *import_traits, imported_by: current_user) }
  let(:import_traits) { [:is_complete, :is_paypal] }
  let!(:imports) { assign(:imports, [import]) }
  let(:tested_can_be_viewed_by) { false }
  let(:disable_import_initiation_message) { nil }

  before do
    view.extend NfgCsvImporter::ImportsHelper
    # TODO: the below works only because the two including applications expose
    # current_user. Instead, we should have an nfg_importer_user that
    # gets its value from the imported_by configuration setting. We  should
    # also consider changing that to configuration setting from being a class
    # to being the helper method in the included application (ie. current_user, current_admin, etc)
    view.stubs(:current_user).returns(current_user)
    view.stubs(:import).returns(import)
    view.stubs(:disable_import_initiation_message).returns(disable_import_initiation_message)
  end

  subject { render }

  context 'when disable_import_initiation_message returns nil' do
    it 'renders the header with a CTA link' do
      expect(subject).to have_css "[data-describe='import-data-onboarder-cta']"
    end
  end

  context "when the disable_import_initiation_message returns a message" do
    let(:disable_import_initiation_message) { 'No Imports Today' }

    it 'does not render the header with a CTA link' do
      expect(subject).not_to have_css "[data-describe='import-data-onboarder-cta']"
    end

    it 'displays the message from the disable_import_initiation_message' do
      expect(subject).to have_content(disable_import_initiation_message)
    end
  end

  describe 'the imports listing' do
    context 'when imports are present' do
      it 'does not display the empty state' do
        expect(subject).not_to have_css "[data-describe='imports-empty-state']"
      end

      it 'displays the listing rows' do
        and_it 'displays the listing row container' do
          expect(subject).to have_css '#imports_listing'
        end

        and_it 'renders the import slat' do
          expect(subject).to render_template 'nfg_csv_importer/imports/_import', count: 1
        end
      end
    end

    context 'when imports are not present' do
      let!(:imports) { assign(:imports, []) }
      it 'displays the empty state' do
        expect(subject).to have_css "[data-describe='imports-empty-state']"

        and_it 'does not display the listing row container' do
          expect(subject).not_to have_css '#imports_listing'
        end

        and_it 'does not render an import slat' do
          expect(subject).not_to render_template 'nfg_csv_importer/imports/_import'
        end
      end
    end
  end
end
