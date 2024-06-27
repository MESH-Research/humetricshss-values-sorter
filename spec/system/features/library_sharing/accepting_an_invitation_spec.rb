# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Accepting a sharing invitation" do
  let(:user) { nil }
  let(:library_owner) { create(:user, first_name: "Library", last_name: "Owner") }
  let(:library) { library_owner.library }

  before do
    sign_in user if user.present?
    visit library_join_path(library_id: library.id, sharing_code: library.sharing_code)
  end

  it "shows the sign in page, and adds the user as a guest when they sign in" do
    expect(page).to have_content "You need to sign in or sign up before continuing."

    logged_in_user = create(:user)
    fill_in "Email", with: logged_in_user.email
    fill_in "Password", with: logged_in_user.password
    click_button "Log in"

    expect(page).to have_content "Successfully joined Library Owner's library"
    expect(page).to have_content "Library Owner's Library"
    expect(logged_in_user.reload.shared_libraries).to contain_exactly(library)
  end

  it "shows the sign in page, and adds the user as a guest when they sign up" do
    expect(page).to have_content "You need to sign in or sign up before continuing."

    click_link "Sign up"
    click_link "Sign up with email"

    fill_in "First name", with: "New"
    fill_in "Last name", with: "User"
    fill_in "Email", with: "newuser@example.com"
    fill_in "user_password", with: "@g00dP@SSW0rd"
    fill_in "user_password_confirmation", with: "@g00dP@SSW0rd"
    choose "No, not right now"
    check "I have read and accept the Code of Conduct"
    click_button "Create account"

    new_user = User.find_by(email: "newuser@example.com")

    expect(page).to have_content "Successfully joined Library Owner's library"
    expect(page).to have_content "Library Owner's Library"
    expect(new_user.shared_libraries).to contain_exactly(library)
  end

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it "adds the user as a guest and displays the library" do
      expect(page).to have_content "Successfully joined Library Owner's library"
      expect(page).to have_content "Library Owner's Library"
      expect(user.reload.shared_libraries).to contain_exactly(library)
    end

    context "when the user is already a guest of the library" do
      let(:user) { create(:library_guest, library: library).guest }

      it "displays an error and shows the library" do
        expect(page).to have_content "Guest has already joined this library"
        expect(page).to have_content "Library Owner's Library"
      end
    end
  end

  context "when the library owner is logged in" do
    let(:user) { library.owner }

    it "displays an error and shows the library" do
      expect(page).to have_content "Guest must not be the library's owner"
      expect(page).to have_content "My Library"
    end
  end
end
