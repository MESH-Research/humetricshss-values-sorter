# frozen_string_literal: true

class RenameIconUrlToIconClass < ActiveRecord::Migration[6.1]
  def change
    rename_column :activities, :icon_url, :icon_class
    rename_column :values, :icon_url, :icon_class
  end
end
