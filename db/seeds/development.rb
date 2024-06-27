# frozen_string_literal: true

# TRICKY: This script may be run in environments where database entries persist between runs. All code in this file and
# the other seed files should be idempotent to avoid possible errors

# Advice seeds
main_library = Library.main

if main_library.advice.none?
  puts "\n== No main library Advice found - seeding Advice =="
  tag_helper = Class.new { include ActionView::Helpers::TagHelper }.new

  main_library.activities.find_each do |activity|
    main_library.values.find_each do |value|
      Random.rand(0..5).times do
        details = Array.new(Random.random_number * 4)
                       .map { Faker::Lorem.paragraph(sentence_count: 4, random_sentences_to_add: 4) }
                       .map { |p_content| tag_helper.tag.p(p_content) }
                       .join("\n")
                       .presence

        main_library.advice.create(
          activity: activity,
          value: value,
          text: "To do #{activity.name} with #{value.name}, " \
                "consider: #{Faker::Lorem.question(word_count: 5, random_words_to_add: 5)}",
          published_state: 1,
          details: details
        )
      end
    end
  end
end

# User seeds
if User.member.none?
  puts "\n== No member-role Users found - seeding Users =="

  user = User.create!(
    first_name: "Member",
    last_name: "User",
    email: "member@example.com",
    password: "password",
    password_confirmation: "password",
    role: :member,
    terms_of_service: true
  )

  puts "\n== Seeding member library =="
  Random.rand(1..3).times do
    user.library.activities.create!(
      name: Faker::Lorem.words.join(" "),
      icon_class: "fas fa-users",
    )
  end

  Random.rand(1..3).times do
    user.library.values.create!(
      name: Faker::Lorem.word,
      icon_class: "fas fa-users"
    )
  end

  tag_helper = Class.new { include ActionView::Helpers::TagHelper }.new
  user.library.activities.find_each do |activity|
    user.library.values.find_each do |value|
      Random.rand(0..5).times do
        details = Array.new(Random.random_number * 4)
                       .map { Faker::Lorem.paragraph(sentence_count: 4, random_sentences_to_add: 4) }
                       .map { |p_content| tag_helper.tag.p(p_content) }
                       .join("\n")
                       .presence

        user.library.advice.create!(
          activity: activity,
          value: value,
          text: "To do #{activity.name} with #{value.name}, " \
                "consider: #{Faker::Lorem.question(word_count: 5, random_words_to_add: 5)}",
          published_state: 1,
          details: details
        )
      end
    end
  end
end

if User.contributor.none?
  puts "\n== No contributor-role Users found - seeding Users =="

  contributor_user = User.create!(
    first_name: "Contributor",
    last_name: "User",
    email: "contributor@example.com",
    password: "password",
    password_confirmation: "password",
    role: :contributor,
    terms_of_service: true
  )

  ContributorApplication.create!(
    user: contributor_user,
    discovery: Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 4),
    interest: Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 4),
    perspective: Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 4),
    status: :accepted
  )
end
