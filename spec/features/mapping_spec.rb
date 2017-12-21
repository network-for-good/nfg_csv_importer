require 'rails_helper'

describe "mapping column headers", js: true do
  let(:entity) { Entity.create(subdomain: "test") }
  let(:admin) {  create(:user) }
  let(:import_file) { File.open("spec/fixtures/subscribers.csv") }
  let!(:import) { create(:import, imported_for: entity, imported_by: admin, status: :uploaded, import_file: import_file) }

  before do
    import.update(fields_mapping: NfgCsvImporter::FieldsMapper.new(import).call)
    visit nfg_csv_importer.edit_import_path(import)
    sleep 1
  end

  context 'when the column headers contain brackets' do
    let(:import_file) { File.open("spec/fixtures/brackets.csv") }

    it 'allows you to map and ignore columns' do
      within "[data-column-name='\[ignore_me\]']" do
        expect do
          find('label.c-checkbox').click
          sleep 1
        end.to change { import.reload.fields_mapping['[ignore_me]'] }.from(nil).to('ignore_column')
      end

      within "[data-column-name='\[first_name\]']" do
      click_link 'Edit Column'
        expect do
          select 'Full Name', from: 'import_fields_mapping_W2ZpcnN0X25hbWVd_'
          sleep 1
        end.to change { import.reload.fields_mapping['[first_name]'] }.from('first_name').to('full_name')
      end
    end
  end
end
