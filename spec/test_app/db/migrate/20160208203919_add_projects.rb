class AddProjects < ActiveRecord::Migration[4.2]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :description
      t.integer :cause_id
    end
  end
end
