# frozen_string_literal: true

class AddDetailsToAdvice < ActiveRecord::Migration[6.1]
  def change
    add_column :advice, :details, :string
  end
end
