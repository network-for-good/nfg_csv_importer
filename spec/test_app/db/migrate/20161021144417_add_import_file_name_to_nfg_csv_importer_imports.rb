class AddImportFileNameToNfgCsvImporterImports < ActiveRecord::Migration
  def change
    add_column :nfg_csv_importer_imports, :import_file_name, :string
  end
end
