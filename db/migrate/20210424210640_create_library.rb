# frozen_string_literal: true

class CreateLibrary < ActiveRecord::Migration[6.1]
  class Library < ApplicationRecord
    # TRICKY: This MUST have parity with the constant on the actual model class
    MAIN_LIBRARY_ID = "9bd2ecee-dfc8-46bc-8184-c0d2ece85080"
  end

  def up
    create_table :libraries, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid, index: { unique: true }

      t.timestamps
    end

    Library.create!(id: Library::MAIN_LIBRARY_ID)

    add_reference :activities, :library, type: :uuid, foreign_key: true
    Activity.update_all(library_id: Library::MAIN_LIBRARY_ID)
    change_column_null :activities, :library_id, false

    add_reference :values, :library, type: :uuid, foreign_key: true
    Value.update_all(library_id: Library::MAIN_LIBRARY_ID)
    change_column_null :values, :library_id, false

    add_reference :advice, :library, type: :uuid, foreign_key: true
    Advice.update_all(library_id: Library::MAIN_LIBRARY_ID)
    change_column_null :advice, :library_id, false
  end

  def down
    raise ActiveRecord::IrreversibleMigration, <<~MESSAGE
      This migration adds Libraries, which separate Advice into several different groups owned by different Users. To
      revese it we must choose a strategy to handle the Advice outside the main Library, which will effectively be the
      only Library once changes are reversed
    MESSAGE
  end
end
