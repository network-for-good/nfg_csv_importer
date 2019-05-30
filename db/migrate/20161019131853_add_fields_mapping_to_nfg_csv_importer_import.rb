class AddFieldsMappingToNfgCsvImporterImport < ActiveRecord::Migration[4.2]
  def change
    add_column :nfg_csv_importer_imports, :fields_mapping, :text
  end
end
