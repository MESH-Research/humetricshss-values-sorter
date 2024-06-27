# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Removing a guest" do
  let(:user) { nil }
  let(:library) { create(:user).library }
  let(:guest) { create(:user, first_name: "Guest", last_name: "User") }
  let!(:library_guest) { create(:library_guest, library: library, guest: guest) }

  before do
    sign_in user if user.present?
    visit edit_library_path(library)
  end

  it_behaves_like "it shows a 404 page"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 404 page"
  end

  context "when the library owner is logged in" do
    let(:user) { library.owner }

    it "allows the user to remove the guest" do
      expect(page).to have_content "Manage My Library"
      expect(page).to have_content "Guest User"

      expect do
        accept_prompt do
          click_link "Remove", href: library_library_guest_path(library, library_guest)
        end

        expect(page).to have_content "Manage My Library"
        expect(page).not_to have_content "Guest User"
      end.to change { library.reload.guests.size }.from(1).to(0)
    end
  end
end
