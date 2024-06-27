# frozen_string_literal: true

class AddRoleToUsers < ActiveRecord::Migration[6.1]
  class User < ApplicationRecord
    enum role: { member: 0, contributor: 1, admin: 2 }
  end

  def up
    add_column :users, :role, :integer, null: false, default: 0

    User.update_all(role: :admin)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, <<~MESSAGE
      This migration adds the distinction between admin and regular users. Before this migration _all_ users were
      admins. To reverse it we must either:

      - make all users admins
      - remove all admin users

      Neither of these are safe in production at any point where users may have been added after this migration has
      run, so we opt not to allow rollback
    MESSAGE
  end
end
