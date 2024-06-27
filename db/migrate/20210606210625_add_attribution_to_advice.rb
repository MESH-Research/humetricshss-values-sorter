# frozen_string_literal: true

class AddAttributionToAdvice < ActiveRecord::Migration[6.1]
  def change
    add_column :advice, :attribution, :string, null: false, default: ""
  end
end
