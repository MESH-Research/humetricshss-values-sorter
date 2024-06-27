# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing an activity" do
  let(:user) { nil }
  let(:library) { create(:user).library }
  let(:activity) { create(:activity, library: library, name: "the old activity") }

  before do
    sign_in user if user.present?
    visit edit_library_activity_path(library, activity)
  end

  it_behaves_like "it shows a 404 page"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 404 page"
  end

  context "when the library owner is logged in" do
    let(:user) { library.owner }

    it "allows the user to edit the activity" do
      expect(page).to have_content "Edit Activity"

      fill_in "Name", with: "the new activity"
      expect { click_button "Save Activity" }.to change { activity.reload.name }.from("the old activity").to("the new activity")

      expect(page).to have_content "Manage My Library"
      expect(page).not_to have_content "the old activity"
      expect(page).to have_content "the new activity"
    end
  end
end
