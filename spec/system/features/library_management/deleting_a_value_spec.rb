# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Deleting a value" do
  let(:user) { nil }
  let(:library) { create(:user).library }
  let(:value) { create(:value, library: library, name: "the value") }

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

    it "allows the user to delete the value" do
      expect(page).to have_content "Edit Value"

      expect do
        accept_prompt do
          click_link "Delete Value", href: library_value_path(library, value)
        end

        expect(page).to have_content "Manage My Library"
      end.to change { library.reload.values.size }.from(1).to(0)

      expect(page).not_to have_content "the value"
    end
  end
end
