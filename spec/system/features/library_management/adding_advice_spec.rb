# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding advice" do
  let(:user) { nil }
  let(:library) { create(:user).library }
  let!(:activity) { create(:activity, library: library, name: "the activity") }
  let!(:value) { create(:value, library: library, name: "the value") }

  before do
    sign_in user if user.present?
    visit new_library_advice_path(library)
  end

  it_behaves_like "it shows a 404 page"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 404 page"
  end

  context "when the library owner is logged in" do
    let(:user) { library.owner }

    it "allows the user to create new advice" do
      expect(page).to have_content "Add New Advice"

      select "the activity", from: "Activity"
      select "the value", from: "Value"
      fill_in "Text", with: "Some advice"

      expect { click_button "Save Advice" }.to change { library.reload.advice.size }.from(0).to(1)
      advice = Advice.find_by(text: "Some advice")

      expect(page).to have_content "Manage My Library"
      expect(page).to have_content "Some advice"
      expect(page).to have_link href: edit_library_advice_path(library, advice)
    end
  end
end
