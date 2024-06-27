# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :activities, id: :uuid do |t|
      t.string :name
      t.string :icon_url

      t.timestamps
    end

    add_index :activities, :name, unique: true
  end
end
