class AddPreProcessingTypeToImports < ActiveRecord::Migration[5.2]
  def change
    add_column :nfg_csv_importer_imports, :pre_processing_type, :string
  end
end
