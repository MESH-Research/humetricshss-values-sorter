# frozen_string_literal: true

OmniAuth.config.test_mode = true

module OmniAuth::Test::Helpers
  DEFAULT_UID = "0000-0000-0000-0000"
  DEFAULT_EMAIL = "jsmith@example.com"
  DEFAULT_FIRST_NAME = "John"
  DEFAULT_LAST_NAME = "Smith"

  def stub_orcid_error(error = nil)
    OmniAuth.config.mock_auth[:orcid] = error || :generic_error
  end

  def stub_orcid_response(**attributes)
    OmniAuth.config.mock_auth[:orcid] = OmniAuth::AuthHash.new(
      "provider": "orcid",
      "uid": attributes[:uid] || DEFAULT_UID,
      "info": {
        "email": attributes[:email] || DEFAULT_EMAIL,
        "first_name": attributes[:first_name] || DEFAULT_FIRST_NAME,
        "last_name": attributes[:last_name] || DEFAULT_LAST_NAME
      }
    )
  end
end

RSpec.configure do |config|
  config.include OmniAuth::Test::Helpers, type: :system

  config.after(:each, type: :system) { OmniAuth.config.mock_auth[:orcid] = nil }
end
