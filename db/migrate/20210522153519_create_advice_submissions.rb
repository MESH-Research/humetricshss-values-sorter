# frozen_string_literal: true

class CreateAdviceSubmissions < ActiveRecord::Migration[6.1]
  def change
    create_table :advice_submissions, id: :uuid do |t|
      t.references :source_advice, foreign_key: { to_table: :advice }, type: :uuid
      t.references :published_advice, foreign_key: { to_table: :advice }, type: :uuid

      t.string :author_name, null: false, default: ""

      t.string :custom_activity, null: false, default: ""
      t.references :published_activity, foreign_key: { to_table: :activities }, type: :uuid

      t.string :custom_value, null: false, default: ""
      t.references :published_value, foreign_key: { to_table: :values }, type: :uuid

      t.string :text, null: false

      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
