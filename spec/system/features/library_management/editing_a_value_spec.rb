# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing a value" do
  let(:user) { nil }
  let(:library) { create(:user).library }
  let(:value) { create(:value, library: library, name: "the old value") }

  before do
    sign_in user if user.present?
    visit edit_library_value_path(library, value)
  end

  it_behaves_like "it shows a 404 page"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 404 page"
  end

  context "when the library owner is logged in" do
    let(:user) { library.owner }

    it "allows the user to edit the value" do
      expect(page).to have_content "Edit Value"

      fill_in "Name", with: "the new value"
      expect { click_button "Save Value" }.to change { value.reload.name }.from("the old value").to("the new value")

      expect(page).to have_content "Manage My Library"
      expect(page).not_to have_content "the old value"
      expect(page).to have_content "the new value"
    end
  end
end
