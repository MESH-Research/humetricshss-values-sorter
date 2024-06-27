# frozen_string_literal: true

class RemoveActionDescriptionDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:activities, :action_description, from: "", to: nil)
  end
end
