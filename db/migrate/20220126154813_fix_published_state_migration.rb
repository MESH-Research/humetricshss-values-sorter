# frozen_string_literal: true

class FixPublishedStateMigration < ActiveRecord::Migration[6.1]
  def up
    # TRICKY: this column was accidentally added in a migration which had already run on some environments. This fix
    # only needs to apply in environments where the column does not exist
    return if ActiveRecord::Base.connection.column_exists?(:advice, :published_state)

    add_column :advice, :published_state, :integer, null: false, default: 1
  end

  def down
    remove_column :advice, :published_state
  end
end
