# frozen_string_literal: true

class CreateLibraryGuests < ActiveRecord::Migration[6.1]
  def change
    create_table :library_guests, id: :uuid do |t|
      t.references :library, foreign_key: true, type: :uuid
      t.references :guest, foreign_key: { to_table: :users }, type: :uuid

      t.timestamps
    end
  end
end
