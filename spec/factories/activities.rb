# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    library { Library.main }
    sequence(:name) { |n| "Activity #{n}" }
    icon_class { "fas fa-balance-scale" }
  end
end
