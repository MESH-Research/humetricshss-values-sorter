# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing advice" do
  let(:user) { nil }
  let(:library) { create(:user).library }
  let(:activity) { create(:activity, library: library, name: "the activity") }
  let(:old_value) { create(:value, library: library, name: "the old value") }
  let!(:new_value) { create(:value, library: library, name: "the new value") }
  let(:advice) { create(:advice, library: library, activity: activity, value: old_value, text: "The old advice") }

  before do
    sign_in user if user.present?
    visit edit_library_advice_path(library, advice)
  end

  it_behaves_like "it shows a 404 page"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 404 page"
  end

  context "when the library owner is logged in" do
    let(:user) { library.owner }

    it "allows the user to edit the advice" do
      expect(page).to have_content "Edit Advice"

      select "the new value", from: "Value"
      fill_in "Text", with: "The new advice"
      click_button "Save Advice"

      expect(page).to have_content "Manage My Library"
      expect(advice.reload).to have_attributes(activity: activity, value: new_value, text: "The new advice")
      expect(page).not_to have_content "The old advice"
      expect(page).to have_content "The new advice"
    end
  end
end
