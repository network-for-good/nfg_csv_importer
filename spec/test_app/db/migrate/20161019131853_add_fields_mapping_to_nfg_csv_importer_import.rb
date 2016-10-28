class AddFieldsMappingToNfgCsvImporterImport < ActiveRecord::Migration
  def change
    add_column :nfg_csv_importer_imports, :fields_mapping, :text
  end
end
