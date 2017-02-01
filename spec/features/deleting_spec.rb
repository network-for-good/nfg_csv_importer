require 'rails_helper'

describe "Deleting imports", js: true do
  let(:entity) { create(:entity) }
  let(:import_type) { "users" }
  let(:admin) {  create(:user) }
  let(:file_name) { "/subscribers.csv" }
  let(:file) { File.open("spec/fixtures#{file_name}") }
  let(:error_file) { nil }
  let(:status) { :complete }
  let(:import) { create(:import, {
    imported_for: entity, import_type: import_type, imported_by: admin,
    import_file: file, error_file: error_file, status: status,
    processing_finished_at: 5.minutes.ago
  })}

  let(:importable) { create(:user, entity: entity) }
  let!(:imported_record) { create(:imported_record, import: import, importable: importable, imported_for: entity, imported_by: admin) }

  it 'works' do
    visit nfg_csv_importer.import_path(import)
    sleep 10
  end
end
