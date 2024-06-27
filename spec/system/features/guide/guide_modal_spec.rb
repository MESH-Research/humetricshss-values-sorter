# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Guide Modal" do
  let(:user) { create(:user) }
  let(:contributor) { false }

  it "Only shows button to logged in users" do
    expect(page).to have_no_content(id: "guide_btn")
  end

  before do
    visit root_path

    click_link "Sign up"
    click_link "Sign up with email"
    expect(page).to have_content "Sign up for your account"

    fill_in "First name", with: "Jane"
    fill_in "Last name", with: "Janely"
    fill_in "Email", with: "jjanely@example.com"
    fill_in "user_password", with: "@g00dP@SSW0rd"
    fill_in "user_password_confirmation", with: "@g00dP@SSW0rd"
    choose((contributor ? "Yes" : "No, not right now"))
    check "I have read and accept the Code of Conduct"
    click_button "Create account"
  end

  context "on registration" do
    context "as a member" do
      it "appears on Sign up" do
        expect(page).to have_content "Welcome to the HuMetricsHSS Values-Sorter"
      end
    end

    context "as a contributor" do
      let(:contributor) { true }
      it "does not appear on Sign up" do
        expect(page).to_not have_content "Welcome to the HuMetricsHSS Values-Sorter"
      end

      it "appears after contributor form" do
        fill_in "contributor_application_discovery", with: "I discovered the application via referral"
        fill_in "contributor_application_interest", with: "I want to help make academia more accessible"
        fill_in "contributor_application_perspective", with: "I am a professor at AAA University"
        click_button "Apply to be a contributor"
        expect(page).to_not have_content "Welcome to the HuMetricsHSS Values-Sorter"
        click_link "Go to library"
        expect(page).to have_content "Welcome to the HuMetricsHSS Values-Sorter"
      end
    end
  end

  context "on upgrade" do
    let(:contributor) { false }
    it "shows after registration, but not after registering as a contributor" do
      expect(page).to have_content "Welcome to the HuMetricsHSS Values-Sorter"
      click_button "Skip"
      click_link "Apply to be a contributor"
      fill_in "contributor_application_discovery", with: "I discovered the application via referral"
      fill_in "contributor_application_interest", with: "I want to help make academia more accessible"
      fill_in "contributor_application_perspective", with: "I am a professor at AAA University"
      click_button "Apply to be a contributor"
      expect(page).to have_content "Thank you for applying to be a HuMetrics contributor!"
      click_link "Go to library"
      expect(page).to_not have_content "Welcome to the HuMetricsHSS Values-Sorter"
    end
  end

  it "Navigates as intended" do
    # #starts on first slide
    expect(page).to have_content "Welcome to"

    # #closes when expected
    click_button "Skip"
    expect(page).to have_no_content("Welcome to")

    # #re-opens via guide button
    find(id: "guide_btn").click
    expect(page).to have_content "Welcome to"

    # #navigates to second slide
    click_button "Continue"

    # #second slide behaves as it should both forward & back
    expect(page).to have_content "Homepage"
    click_button "Back"
    expect(page).to have_content "Welcome to"
    click_button "Continue"
    expect(page).to have_content "Homepage"
    click_button "Continue"

    # #third slide behaves as it should both forward & back
    expect(page).to have_content "Published Library"
    click_button "Back"
    expect(page).to have_content "Homepage"
    click_button "Continue"
    expect(page).to have_content "Published Library"
    click_button "Continue"

    # #fourth slide behaves as it should both forward & back
    expect(page).to have_content "Contribute Advice"
    click_button "Back"
    expect(page).to have_content "Published Library"
    click_button "Continue"
    expect(page).to have_content "Contribute Advice"
    click_button "Continue"

    # #fifth slide behaves as it should both forward & back
    expect(page).to have_content "Manage Your Library"
    click_button "Back"
    expect(page).to have_content "Contribute Advice"
    click_button "Continue"
    expect(page).to have_content "Manage Your Library"
    click_button "Continue"

    # #final slide behaves as it should both forward & back
    expect(page).to have_content "Inviting Guests"
    expect(page).to have_content "Back"
    expect(page).to have_content "Close"
    click_button "Back"
    expect(page).to have_content "Manage Your Library"
    click_button "Continue"
    expect(page).to have_content "Inviting Guests"
    click_button "Close"
    expect(page).to have_no_content("Inviting Guests")
  end
  context "when accessed from a mobile device", :mobile do
    it "Only shows button to logged in users" do
      expect(page).to have_no_content(id: "guide_btn")
    end
    it "Appears on Sign up" do
      expect(page).to have_content "Skip"
      expect(page).to have_content "Continue"
      expect(page).to have_content "Quick Tour"
    end

    it "Navigates as intended" do
      # #starts on first slide
      expect(page).to have_content "Welcome to"

      # #closes when expected
      click_button "Skip"
      expect(page).to have_no_content("Welcome to")

      # #re-opens via guide button
      find(id: "guide_btn").click
      expect(page).to have_content "Welcome to"

      # #navigates to second slide
      click_button "Continue"

      # #second slide behaves as it should both forward & back
      expect(page).to have_content "Homepage"
      click_button "Back"
      expect(page).to have_content "Welcome to"
      click_button "Continue"
      expect(page).to have_content "Homepage"
      click_button "Continue"

      # #third slide behaves as it should both forward & back
      expect(page).to have_content "Published Library"
      click_button "Back"
      expect(page).to have_content "Homepage"
      click_button "Continue"
      expect(page).to have_content "Published Library"
      click_button "Continue"

      # #fourth slide behaves as it should both forward & back
      expect(page).to have_content "Contribute Advice"
      click_button "Back"
      expect(page).to have_content "Published Library"
      click_button "Continue"
      expect(page).to have_content "Contribute Advice"
      click_button "Continue"

      # #fifth slide behaves as it should both forward & back
      expect(page).to have_content "Manage Your Library"
      click_button "Back"
      expect(page).to have_content "Contribute Advice"
      click_button "Continue"
      expect(page).to have_content "Manage Your Library"
      click_button "Continue"

      # #final slide behaves as it should both forward & back
      expect(page).to have_content "Inviting Guests"
      expect(page).to have_content "Back"
      expect(page).to have_content "Close"
      click_button "Back"
      expect(page).to have_content "Manage Your Library"
      click_button "Continue"
      expect(page).to have_content "Inviting Guests"
      click_button "Close"
      expect(page).to have_no_content("Inviting Guests")
    end
  end
end
