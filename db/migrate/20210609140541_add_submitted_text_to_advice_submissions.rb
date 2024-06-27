# frozen_string_literal: true

class AddSubmittedTextToAdviceSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :advice_submissions, :submitted_text, :string, null: false, default: ""
    change_column_default :advice_submissions, :submitted_text, from: "", to: nil
  end
end
