# This migration comes from nfg_csv_importer (originally 20160205231646)
class CreateNfgCsvImporterImportedRecords < ActiveRecord::Migration
  def change
    create_table "nfg_csv_importer_imported_records" do |t|
      t.integer  "imported_for_id"
      t.integer  "imported_by_id"
      t.string   "action"
      t.integer  "importable_id"
      t.string   "importable_type"
      t.string   "transaction_id"
      t.timestamps
    end
  end
end
