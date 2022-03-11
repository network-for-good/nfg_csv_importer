require 'rails_helper'

RSpec.describe 'nfg_csv_importer/imports/_mapped_column_headers.html.haml' do
  let!(:entity) { FactoryBot.create(:entity) }
  let!(:user) { FactoryBot.create(:user) }
  let(:max_height) { nil }
  let(:import) { FactoryBot.create(:import) }

  subject { render partial: 'nfg_csv_importer/imports/mapped_column_headers', locals: { import: import, max_height: max_height } }

  describe 'expandable container' do
    context 'when max_height is not supplied in locals' do
      it 'applies the default fallback max height' do
        expect(subject).to have_css ".expandable[data-max-height='300']"
      end
    end

    context 'when max_height is supplied in locals' do
      let(:max_height) { 200 }

      it 'applies the supplied local max_height as a number string' do
        expect(subject).to have_css ".expandable[data-max-height='#{max_height}']"
      end
    end
  end

  describe 'mapped column headers listing' do
    let(:import) { FactoryBot.create(:import, fields_mapping: fields_mapping) }
    let(:original_header_name) { 'test' }
    let(:new_header_name) { 'test2' }
    let(:fields_mapping) { {} }

    describe 'unignored/active mapped column headers' do
      let(:fields_mapping) { { original_header_name => new_header_name } }

      it 'outputs the legacy and new column header names' do
        expect(subject).to have_css "[data-describe='mapped-column-header']"

        and_it 'shows the original name' do
          expect(subject).to have_selector "[data-describe='original-column-header']", text: original_header_name
        end

        and_it 'shows the new name' do
          expect(subject).to have_selector "[data-describe='new-column-header']", text: new_header_name
        end
      end
    end

    describe 'ignored column headers' do
      context 'when there are no ignored columns' do
        let(:fields_mapping) { { original_header_name => new_header_name } }

        it 'does not show the ignored columns' do
          expect(subject).not_to have_css "[data-describe='ignored-columns']"
        end
      end

      context 'when there are ignored columns' do
        let(:ignored_header_column) { 'ignore_me' }
        let(:fields_mapping) { { ignored_header_column => 'ignore_column' } }
        it 'shows the ignored columns' do
          expect(subject).to have_css "[data-describe='ignored-columns']"

          and_it 'lists the name of the ignored column' do
            expect(subject).to have_selector "[data-describe='ignored-column-header']", text: ignored_header_column
          end
        end
      end
    end
  end
end
