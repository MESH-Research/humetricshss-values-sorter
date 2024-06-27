# frozen_string_literal: true

class RemoveActionDescriptionFromActivities < ActiveRecord::Migration[6.1]
  class Activity < ApplicationRecord; end

  def up
    puts "-- setting name to action_description --"
    Activity.update_all("name = action_description")

    remove_column :activities, :action_description
  end

  def down
    add_column :activities, :action_description, :string

    puts "-- repopulating action_description from name --"
    Activity.update_all("action_description = name")

    change_column_null :activities, :action_description, false
  end
end
