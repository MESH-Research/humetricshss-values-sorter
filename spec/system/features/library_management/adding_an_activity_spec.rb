# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding an activity" do
  let(:user) { nil }
  let(:library) { create(:user).library }

  before do
    sign_in user if user.present?
    visit new_library_activity_path(library)
  end

  it_behaves_like "it shows a 404 page"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 404 page"
  end

  context "when the library owner is logged in" do
    let(:user) { library.owner }

    it "allows the user to create a new activity" do
      expect(page).to have_content "Add New Activity"

      fill_in "Name", with: "a new activity"
      expect { click_button "Save Activity" }.to change { library.reload.activities.size }.from(0).to(1)
      activity = Activity.find_by(name: "a new activity")

      expect(page).to have_content "Manage My Library"
      expect(page).to have_content "a new activity"
      expect(page).to have_link href: edit_library_activity_path(library, activity)
    end
  end
end
