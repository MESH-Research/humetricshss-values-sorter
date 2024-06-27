# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Signing into an account" do
  let(:user) { create(:user) }

  before do
    visit root_path

    click_link "Sign in"
    expect(page).to have_content "Sign in"
  end

  context "with email" do
    it "starts a session and redirects to the correct page" do
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password

      click_button "Log in"

      expect(page).not_to have_link "Sign in", href: new_user_session_path
      expect(page).not_to have_link "Sign up", href: new_user_registration_path
      expect(page).to have_link "Sign out", href: destroy_user_session_path

      expect(page).to have_content <<~TEXT
        HuMetricsHSS Published Library
        My Library
      TEXT
    end
  end

  context "with ORCID" do
    context "when ORCID auth fails" do
      before do
        stub_orcid_error

        click_link "Continue with ORCID"
      end

      it "displays the error and returns to the correct page" do
        expect(page).to have_link "Sign in", href: new_user_session_path
        expect(page).to have_link "Sign up", href: new_user_registration_path
        expect(page).not_to have_link "Sign out", href: destroy_user_session_path

        expect(page).to have_content "Couldn't sign in with ORCID"
        expect(page).to have_content "Live your values. Transform the academy."
      end
    end

    context "when the user has not signed up" do
      before do
        stub_orcid_response(uid: "0000-0001-0002-0003", first_name: "Heidi", email: "heidi@example.com")

        click_link "Continue with ORCID"
      end

      it "redirects to the sign up flow" do
        expect(page).to have_link "Sign in", href: new_user_session_path
        expect(page).to have_link "Sign up", href: new_user_registration_path
        expect(page).not_to have_link "Sign out", href: destroy_user_session_path

        expect(page).to have_content "Sign up with ORCID"
      end
    end

    context "when the user has signed up" do
      before do
        create(:user, provider: "orcid", uid: "0000-0001-0002-0003")
        stub_orcid_response(uid: "0000-0001-0002-0003", first_name: "Heidi", email: "heidi@example.com")

        click_link "Continue with ORCID"
      end

      it "starts a session and redirects to the correct page" do
        expect(page).not_to have_link "Sign in", href: new_user_session_path
        expect(page).not_to have_link "Sign up", href: new_user_registration_path
        expect(page).to have_link "Sign out", href: destroy_user_session_path

        expect(page).to have_content <<~TEXT
          HuMetricsHSS Published Library
          My Library
        TEXT
      end
    end
  end
end
