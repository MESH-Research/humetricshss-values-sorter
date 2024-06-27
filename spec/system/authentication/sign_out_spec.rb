# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Signing out of an account" do
  let(:user) { create(:user) }

  before do
    sign_in user
    visit root_path
  end

  it "allows a user to sign out and shows the expected page" do
    click_link "Sign out"

    expect(page).to have_link "Sign in", href: new_user_session_path
    expect(page).to have_link "Sign up", href: new_user_registration_path
    expect(page).not_to have_link "Sign out", href: destroy_user_session_path
    expect(page).to have_content "Live your values. Transform the academy."
  end
end
