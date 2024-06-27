# frozen_string_literal: true

class ChangeUserNamesNullability < ActiveRecord::Migration[6.1]
  def change
    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
  end
end
