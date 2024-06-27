# frozen_string_literal: true

class CreateContributorApplication < ActiveRecord::Migration[6.1]
  def change
    create_table :contributor_applications, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.text :discovery, null: false
      t.text :interest, null: false
      t.text :perspective, null: false

      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
