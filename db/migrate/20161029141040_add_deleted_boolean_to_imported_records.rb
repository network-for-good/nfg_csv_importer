class AddDeletedBooleanToImportedRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :nfg_csv_importer_imported_records, :deleted, :boolean, default: false
  end
end
