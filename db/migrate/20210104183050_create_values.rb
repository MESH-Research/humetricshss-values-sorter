# frozen_string_literal: true

class CreateValues < ActiveRecord::Migration[6.1]
  def change
    create_table :values, id: :uuid do |t|
      t.string :name
      t.string :icon_url

      t.timestamps
    end

    add_index :values, :name, unique: true
  end
end
