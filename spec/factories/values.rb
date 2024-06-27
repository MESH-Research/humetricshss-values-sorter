# frozen_string_literal: true

FactoryBot.define do
  factory :value do
    library { Library.main }
    sequence(:name) { |n| "Value #{n}" }
    icon_class { "fas fa-balance-scale" }
  end
end
