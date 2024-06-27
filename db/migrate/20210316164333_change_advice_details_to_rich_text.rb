# frozen_string_literal: true

class ChangeAdviceDetailsToRichText < ActiveRecord::Migration[6.1]
  include ActionView::Helpers::TextHelper

  class Advice < ApplicationRecord
    has_rich_text :details
  end

  def up
    rename_column :advice, :details, :html_details

    puts "-- converting advice details to rich text --"
    Advice.where.not(html_details: nil).each do |advice|
      details = simple_format(advice.html_details).tr("\n", "")
      advice.update!(details: details)
    end

    # TRICKY: After the above update the polymorphic association attaches to the ChangeAdviceDetailsToRichText::Advice
    # stub above, and we need to fix it manually
    ActionText::RichText.where(record_type: "ChangeAdviceDetailsToRichText::Advice")
                        .update_all(record_type: "Advice")

    remove_column :advice, :html_details
  end

  def down
    raise ActiveRecord::IrreversibleMigration, <<~MESSAGE
      The switch to Action Text contains additional features which simple_format cannot replicate
      Reversing this migration should be a careful, manual process. The following snippet may help:

      ```ruby
        add_column :advice, :html_details, :text

        rich_texts = ActionText::RichText.includes(:record).where(record_type: "Advice")
        rich_texts.each do |rich_text|
          rich_text.record.update!(html_details: rich_text.to_s)
        end
        rich_texts.destroy_all

        rename_column :advice, :html_details, :details
      ```
    MESSAGE
  end
end
