# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding a value" do
  let(:user) { nil }
  let(:library) { create(:user).library }

  before do
    sign_in user if user.present?
    visit new_library_value_path(library)
  end

  it_behaves_like "it shows a 404 page"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 404 page"
  end

  context "when the library owner is logged in" do
    let(:user) { library.owner }

    it "allows the user to create a new value" do
      expect(page).to have_content "Add New Value"

      fill_in "Name", with: "a new value"
      expect { click_button "Save Value" }.to change { library.reload.values.size }.from(0).to(1)
      value = Value.find_by(name: "a new value")

      expect(page).to have_content "Manage My Library"
      expect(page).to have_content "a new value"
      expect(page).to have_link href: edit_library_value_path(library, value)
    end
  end
end
