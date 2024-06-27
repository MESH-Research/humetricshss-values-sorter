# frozen_string_literal: true

class AddFirstLastNameToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :first_name, :string, null: false, default: ""
    add_column :users, :last_name, :string, null: false, default: ""
  end
end