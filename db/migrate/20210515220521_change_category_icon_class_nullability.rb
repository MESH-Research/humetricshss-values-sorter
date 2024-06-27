# frozen_string_literal: true

class ChangeCategoryIconClassNullability < ActiveRecord::Migration[6.1]
  def change
    change_column_null :activities, :icon_class, true
    change_column_null :values, :icon_class, true
  end
end
