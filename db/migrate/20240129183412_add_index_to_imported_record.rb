class AddIndexToImportedRecord < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    # The syntax for concurrently only works in Postgres
    if ActiveRecord::Base.connection.adapter_name.downcase == "postgresql"
      add_index(
        :nfg_csv_importer_imported_records,
        [:importable_id, :importable_type],
        algorithm: :concurrently,
        name: "idx_imported_records_on_importables"
      )
    else
      add_index(
        :nfg_csv_importer_imported_records,
        [:importable_id, :importable_type],
        name: "idx_imported_records_on_importables"
      )
    end
  end
end
