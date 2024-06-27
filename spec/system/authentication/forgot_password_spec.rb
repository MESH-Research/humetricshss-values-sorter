# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Recovering an account password" do
  let(:user) { create(:user) }

  before { visit root_path }

  it "allows a user to recover their account by emailing them a link" do
    click_link "Sign in"
    expect(page).to have_content "Sign in"

    click_link "Forgot password"
    expect(page).to have_content "Forgot your password"

    fill_in "Email", with: user.email
    expect { click_button "Send link" }.to change { Devise::Mailer.deliveries.size }.from(0).to(1)
    expect(page).to have_content "Check your email. We are sending a reset password link to you."
    expect(page).to have_content "Sign in"

    forgot_pass_email = Devise::Mailer.deliveries.first
    email_content = Capybara.string forgot_pass_email.html_part.body.raw_source

    # TRICKY: This is the WRONG URL. We don't know where Capybara has decided to host itself. We turn this into a path
    # instead of an (incorrect) absolute URL, and then consume that with Capybara, allowing it to assume that we wanted
    # the correct host
    reset_pass_uri = URI(email_content.find_link("Reset Password")["href"])
    reset_pass_path = "#{reset_pass_uri.path}?#{reset_pass_uri.query}"

    visit reset_pass_path
    expect(page).to have_content "Reset your password"
    fill_in "user_password", with: "@g00dP@SSW0rd"
    fill_in "user_password_confirmation", with: "@g00dP@SSW0rd"
    click_button "Save password"

    expect(page).not_to have_link "Sign in", href: new_user_session_path
    expect(page).not_to have_link "Sign up", href: new_user_registration_path
    expect(page).to have_link "Sign out", href: destroy_user_session_path
    expect(page).to have_content "Your password has been changed successfully. You are now signed in."
    expect(page).to have_content <<~TEXT
      HuMetricsHSS Published Library
      My Library
    TEXT
  end
end
