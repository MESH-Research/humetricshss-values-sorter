# frozen_string_literal: true

FactoryBot.define do
  factory :library_guest do
    library { create(:user).library }
    guest { create(:user) }
  end
end
