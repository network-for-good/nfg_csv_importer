class AddStatisticsToImports < ActiveRecord::Migration[5.2]
  def up
    add_column :nfg_csv_importer_imports, :statistics, :string
  end

  def down
    remove_column :nfg_csv_importer_imports, :statistics
  end
end
