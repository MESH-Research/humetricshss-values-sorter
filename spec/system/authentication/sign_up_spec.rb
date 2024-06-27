# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Signing up for an account" do
  before do
    visit root_path

    click_link "Sign up"
  end

  context "when signing up with email" do
    before do
      click_link "Sign up with email"
      expect(page).to have_content "Sign up for your account"

      fill_in "First name", with: "Jane"
      fill_in "Last name", with: "Janely"
      fill_in "Email", with: "jjanely@example.com"
      fill_in "user_password", with: "@g00dP@SSW0rd"
      fill_in "user_password_confirmation", with: "@g00dP@SSW0rd"
      check "I have read and accept the Code of Conduct"
    end

    describe "when not signing up as a contributor" do
      before { choose "No, not right now" }

      it "creates the user and redirects to the correct page" do
        expect { click_button "Create account" }.to change { User.find_by(email: "jjanely@example.com") }.from(nil).to(an_instance_of(User))

        expect(page).not_to have_link "Sign in", href: new_user_session_path
        expect(page).not_to have_link "Sign up", href: new_user_registration_path
        expect(page).to have_link "Sign out", href: destroy_user_session_path

        expect(page).to have_content "Welcome! You have signed up successfully."
        expect(page).to have_content <<~TEXT
          HuMetricsHSS Published Library
          My Library
        TEXT
      end
    end

    describe "when signing up as a contributor" do
      before { choose "Yes" }

      it "creates the user and redirects to the correct page" do
        expect { click_button "Create account" }.to change { User.find_by(email: "jjanely@example.com") }.from(nil).to(an_instance_of(User))

        expect(page).not_to have_link "Sign in", href: new_user_session_path
        expect(page).not_to have_link "Sign up", href: new_user_registration_path
        expect(page).to have_link "Sign out", href: destroy_user_session_path

        expect(page).to have_content "Welcome! You have signed up successfully."
        expect(page).to have_content <<~TEXT
          Become a contributor
          Contributors to the Values-Sorter can create values, activities, and advice to be added to the larger HuMetricsHSS library, for use by all visitors to the site
        TEXT
      end
    end
  end

  context "when signing up with ORCID" do
    context "when ORCID auth fails" do
      before do
        stub_orcid_error

        click_link "Sign up with ORCID"
      end

      it "displays the error and returns to the correct page" do
        expect(page).to have_link "Sign in", href: new_user_session_path
        expect(page).to have_link "Sign up", href: new_user_registration_path
        expect(page).not_to have_link "Sign out", href: destroy_user_session_path

        expect(page).to have_content "Couldn't sign in with ORCID"
        expect(page).to have_content "Live your values. Transform the academy."
      end
    end

    context "when ORCID auth succeeds" do
      before do
        stub_orcid_response(uid: "0000-0001-0002-0003", first_name: "Heidi", email: "heidi@example.com")

        click_link "Sign up with ORCID"
      end

      it "lets the user fill in missing data before creating the user" do
        expect(page).to have_content "Sign up with ORCID"

        fill_in "Last name", with: "Janely"
        choose "No, not right now"
        check "I have read and accept the Code of Conduct"

        expect { click_button "Sign up with ORCID" }.to change { User.find_by(email: "heidi@example.com") }.from(nil).to(an_instance_of(User))
        expect(User.find_by(email: "heidi@example.com")).to have_attributes(provider: "orcid", uid: "0000-0001-0002-0003")

        expect(page).not_to have_link "Sign in", href: new_user_session_path
        expect(page).not_to have_link "Sign up", href: new_user_registration_path
        expect(page).to have_link "Sign out", href: destroy_user_session_path

        expect(page).to have_content "Welcome! You have signed up successfully."
        expect(page).to have_content <<~TEXT
          HuMetricsHSS Published Library
          My Library
        TEXT
      end
    end

    context "when the user has already signed up with an ORCID account" do
      before do
        create(:user, provider: "orcid", uid: "0000-0001-0002-0003")
        stub_orcid_response(uid: "0000-0001-0002-0003", first_name: "Heidi", email: "heidi@example.com")

        click_link "Sign up with ORCID"
      end

      it "signs the user in and redirects to the correct page" do
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
