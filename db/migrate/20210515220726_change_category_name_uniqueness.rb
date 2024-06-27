# frozen_string_literal: true

class ChangeCategoryNameUniqueness < ActiveRecord::Migration[6.1]
  def change
    remove_index :activities, name: "index_activities_on_name"
    remove_index :values, name: "index_values_on_name"
  end
end
