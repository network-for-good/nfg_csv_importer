class CreateEntities < ActiveRecord::Migration[4.2]
  def change
    create_table :entities do |t|
      t.string :subdomain

      t.timestamps
    end
  end
end
