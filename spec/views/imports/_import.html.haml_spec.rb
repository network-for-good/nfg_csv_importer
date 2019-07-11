require 'rails_helper'

RSpec.describe "nfg_csv_importer/imports/_imports.html.haml", type: :view do
  let(:imports_listing_row_column_structure_class) { "col-md-2 m-b-half-down-sm" }
  let(:h) { NfgCsvImporter::ImportsController.new.view_context }
  let(:import) { FactoryGirl.create(:import, *import_traits, imported_by: imported_by) }
  let(:import_traits) { [:is_complete, :is_paypal, :with_pre_processing_files] }
  let(:import_presenter) { NfgCsvImporter::ImportPresenter.new(import, h) }
  let(:current_user) { FactoryGirl.create(:user) }
  let(:imported_by) { current_user }
  let(:tested_can_be_viewed_by) { true }

  before do
    view.stubs(:current_user).returns(current_user)
    import.stubs(:can_be_viewed_by).with(current_user).returns(tested_can_be_viewed_by)
  end

  subject { render partial: 'nfg_csv_importer/imports/import', locals: { import_presenter: import_presenter, import: import, imports_listing_row_column_structure_class: imports_listing_row_column_structure_class } }

  context 'when the user is allowed to view the import details' do
    let(:tested_can_be_viewed_by) { true }

    it 'renders the expected data' do
      expect(subject).to have_css "[data-describe='import-slat']"

      and_it 'displays the imported_by user name' do
        expect(subject).to have_selector "[data-describe='imported-by-name']", text: current_user.name
      end

      and_it 'displays the file origination type name (paypal)' do
        expect(subject).to have_selector "[data-describe='file-origination-type']", text: 'PayPal'
      end

      and_it 'displays the number of imported records' do
        expect(subject).to have_selector "[data-describe='amount-of-records-without-errors']", text: import.records_processed
      end
    end

    context 'and when errors are present' do
      let(:import_traits) { [:is_paypal, :is_complete_with_errors] }
      it 'displays information about the errors' do
        and_it 'displays the count of error rows' do
          expect(subject).to have_selector "[data-describe='number-of-errors']", text: '1'
        end

        and_it 'allows you to download the error file' do
          expect(subject).to have_css "[data-describe='error-file-link']"
        end
      end
    end

    context 'and when errors are not present' do
      it 'does not display error information' do
        and_it 'does not display the count of error rows' do
          expect(subject).not_to have_css "[data-describe='number-of-errors']"
        end

        and_it 'does not allow you to download an error file' do
          expect(subject).not_to have_css "[data-describe='error-file-link']"
        end
      end
    end
  end

  context 'when the user cannot view the import details' do
    let(:tested_can_be_viewed_by) { false }
    it 'does not render the slat' do
      expect(subject).not_to have_css "[data-describe='import-slat']"
    end
  end


end