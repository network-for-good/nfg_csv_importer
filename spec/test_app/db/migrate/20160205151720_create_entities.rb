class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.string :subdomain

      t.timestamps
    end
  end
end
