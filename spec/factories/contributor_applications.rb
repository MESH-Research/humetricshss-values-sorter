# frozen_string_literal: true

FactoryBot.define do
  factory :contributor_application do
    discovery { Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 4) }
    interest { Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 4) }
    perspective { Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 4) }
    status { :pending }

    # TRICKY: We use this build hook to try to transparently maintain the intended application state in tests. Any
    # ContributorApplications without a User are provided one with a sensible role based on their status
    after(:build) do |application|
      unless application.user.present?
        if application.accepted?
          application.user = build(:user, role: :contributor, contributor_application: application)
        else
          application.user = build(:user, role: :member, contributor_application: application)
        end
      end
    end
  end
end
