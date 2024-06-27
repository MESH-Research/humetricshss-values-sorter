# frozen_string_literal: true

FactoryBot.define do
  factory :advice_submission do
    source_advice { build(:advice, :user_created) }
    published_advice { nil }
    author_name { source_advice&.owner&.full_name || "" }

    custom_activity { source_advice&.activity&.name }
    published_activity { nil }
    custom_value { source_advice&.value&.name }
    published_value { nil }

    text { source_advice&.text }
    details { source_advice&.details }

    status { :pending }
  end
end
