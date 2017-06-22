class AddNoteToUser < ActiveRecord::Migration
  def change
    add_column :users, :note, :string
  end
end
