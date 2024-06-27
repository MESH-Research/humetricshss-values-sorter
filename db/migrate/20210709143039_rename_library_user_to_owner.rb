# frozen_string_literal: true

class RenameLibraryUserToOwner < ActiveRecord::Migration[6.1]
  def change
    remove_index :libraries, :user_id, unique: true
    rename_column :libraries, :user_id, :owner_id
    add_index :libraries, :owner_id, unique: true
  end
end
