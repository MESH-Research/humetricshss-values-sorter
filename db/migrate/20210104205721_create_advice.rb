# frozen_string_literal: true

class CreateAdvice < ActiveRecord::Migration[6.1]
  def change
    create_table :advice, id: :uuid do |t|
      t.references :activity, null: false, foreign_key: true, type: :uuid
      t.references :value, null: false, foreign_key: true, type: :uuid
      t.string :text, null: false
      t.timestamps
    end

    add_index :advice, %i[activity_id value_id]
  end
end
