# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.safe_email(name: "#{first_name} #{last_name}") }
    password { Faker::Internet.password(min_length: 8, max_length: 16) }
    password_confirmation { password }
    role { :member }
    terms_of_service { true }
    contributor_application { nil }
    library { Library.new }

    trait :with_contributor_application do
      transient do
        application_status { :pending }
      end

      contributor_application do
        association :contributor_application, status: application_status
      end
    end

    # TRICKY: We use this build hook to try to transparently maintain the intended application state in tests. Any
    # Users with the contributor role are built with an accepted ContributorApplication unless an instance has already
    # been specified
    after(:build) do |user|
      if user.contributor? && user.contributor_application.blank?
        user.contributor_application = build(:contributor_application, user: user, status: :accepted)
      end
    end
  end
end
