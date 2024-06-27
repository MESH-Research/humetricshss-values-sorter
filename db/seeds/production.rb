# frozen_string_literal: true

require "csv"

# TRICKY: This script may be run in environments where database entries persist between runs. All code in this file and
# the other seed files should be idempotent to avoid possible errors

# Advice seeds
main_library = Library.main

if main_library.advice.none?
  puts "\n== No Advice found - seeding Advice =="

  puts "\n== Converting Advice CSV Data =="
  class CSVRowTransformation < Reforge::Transformation
    def self.text_helper
      @text_helper ||= Class.new { include ActionView::Helpers::TextHelper }.new
    end

    extract :library, from: -> { Library.main }, memoize: :first

    extract :activity,
            from: ->(row) { Activity.find_by!(name: row[:activity_name]) },
            memoize: { by: { key: :activity_name } }

    extract :value,
            from: ->(row) { Value.find_by!(name: row[:value_name]) },
            memoize: { by: { key: :value_name } }

    extract :text, from: { key: :advice_text }

    extract :details, from: ->(row) { text_helper.simple_format(row[:advice_details]) }
  end

  advice_filepath = "#{__dir__}/advice_data.csv"
  advice_csv_rows = CSV.read(advice_filepath, headers: true, header_converters: :symbol).map(&:to_h)
  advice_create_hashes = CSVRowTransformation.call(*advice_csv_rows)

  puts "\n== Creating Advice =="
  advice_create_hashes.each { |hash| Advice.create!(hash) }
end
