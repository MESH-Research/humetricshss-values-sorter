# frozen_string_literal: true

class AddSharingIdToLibrary < ActiveRecord::Migration[6.1]
  def change
    add_column :libraries, :sharing_code, :uuid, null: false, default: -> { "gen_random_uuid()" }
    add_index :libraries, :sharing_code
  end
end
