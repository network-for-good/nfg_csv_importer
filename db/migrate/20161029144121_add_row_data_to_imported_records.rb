class AddRowDataToImportedRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :nfg_csv_importer_imported_records, :row_data, :text
  end
end
