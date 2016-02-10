# This migration comes from nfg_csv_importer (originally 20160205151104)
class CreateNfgCsvImporterImports < ActiveRecord::Migration
  def change
    create_table :nfg_csv_importer_imports do |t|
      t.string   "import_type"
      t.string   "import_file"
      t.string   "error_file"
      t.integer  "number_of_records"
      t.integer  "number_of_records_with_errors"
      t.integer  "entity_id"
      t.integer  "imported_by_id"
      t.integer  "status"
      t.integer  "records_processed"
      t.timestamps
    end
  end
end
