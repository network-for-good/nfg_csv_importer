class AddImportIdToImportedRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :nfg_csv_importer_imported_records, :import_id, :integer
    add_index :nfg_csv_importer_imported_records, :import_id
  end
end
