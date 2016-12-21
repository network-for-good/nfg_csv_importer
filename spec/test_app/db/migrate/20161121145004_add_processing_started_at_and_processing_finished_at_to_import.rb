class AddProcessingStartedAtAndProcessingFinishedAtToImport < ActiveRecord::Migration
  def change
    add_column :nfg_csv_importer_imports, :processing_started_at, :datetime
    add_column :nfg_csv_importer_imports, :processing_finished_at, :datetime
  end
end
