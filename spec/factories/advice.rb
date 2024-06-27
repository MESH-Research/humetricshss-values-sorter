# frozen_string_literal: true

FactoryBot.define do
  factory :advice do
    library { Library.main }
    activity { build(:activity, library: library) }
    value { build(:value, library: library) }
    text { Faker::Lorem.question(word_count: 5, random_words_to_add: 10) }
    published_state { :published }
    details do
      tag_helper = Class.new { include ActionView::Helpers::TagHelper }.new

      Array.new(Random.random_number * 4)
            .map { Faker::Lorem.paragraph(sentence_count: 4, random_sentences_to_add: 4) }
            .map { |p_content| tag_helper.tag.p(p_content) }
            .join("\n")
            .presence
    end
    submission { nil }

    trait :user_created do
      library { create(:user).library }
    end

    trait :draft do
      published_state { :draft }
      text { "This is a draft" }
      details { "This is a draft" }
    end
  end
end
