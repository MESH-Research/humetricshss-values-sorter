# frozen_string_literal: true

class AddTosAcceptedToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :terms_of_service, :boolean, null: false, default: true
    change_column_default :users, :terms_of_service, from: true, to: nil
  end
end
