# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Deleting advice" do
  let(:user) { nil }
  let(:library) { create(:user).library }
  let(:advice) { create(:advice, library: library, text: "The advice") }

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

    it "allows the user to delete the advice" do
      expect(page).to have_content "Edit Advice"

      expect do
        accept_prompt do
          click_link "Delete Advice", href: library_advice_path(library, advice)
        end

        expect(page).to have_content "Manage My Library"
      end.to change { library.reload.advice.size }.from(1).to(0)

      expect(page).not_to have_content "The advice"
    end
  end
end
