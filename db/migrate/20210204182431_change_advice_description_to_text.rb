# frozen_string_literal: true

class ChangeAdviceDescriptionToText < ActiveRecord::Migration[6.1]
  def up
    change_column :advice, :details, :text
  end

  def down
    change_column :advice, :details, :string
  end
end
