class AddRowDataToImportedRecords < ActiveRecord::Migration
  def change
    add_column :nfg_csv_importer_imported_records, :row_data, :text
  end
end
