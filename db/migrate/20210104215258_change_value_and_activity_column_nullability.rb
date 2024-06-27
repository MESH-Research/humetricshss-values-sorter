# frozen_string_literal: true

class ChangeValueAndActivityColumnNullability < ActiveRecord::Migration[6.1]
  def change
    change_column_null :activities, :name, false
    change_column_null :activities, :icon_url, false
    change_column_null :values, :name, false
    change_column_null :values, :icon_url, false
  end
end
