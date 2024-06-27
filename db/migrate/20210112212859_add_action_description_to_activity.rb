# frozen_string_literal: true

class AddActionDescriptionToActivity < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :action_description, :string, null: false, default: ""
  end
end
