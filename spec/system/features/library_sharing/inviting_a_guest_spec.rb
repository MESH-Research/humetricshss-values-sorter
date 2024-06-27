# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Inviting a guest" do
  let(:user) { nil }
  let(:library) { create(:user).library }

  before do
    sign_in user if user.present?
    visit new_library_library_guest_path(library)
  end

  it_behaves_like "it shows a 404 page"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 404 page"
  end

  context "when the library owner is logged in" do
    let(:user) { library.owner }

    it "shows the invite page" do
      expect(page).to have_content "Invite a new guest to your library"

      default_invitation = "Join my HuMetrics Library!\n\n" \
      "HuMetricsHSS is an initiative for rethinking humane indicators of excellence in academia, focused " \
      "particularly on the humanities and social sciences (HSS). I’m using this tool to guide thinking to a more " \
      "values-enacted approach to all kinds of academic work. I’ve created my own library with a set of values " \
      "and activities.\n\n" \
      "Click this link to join my library:"
      library_join_path = library_join_path(library_id: library.id, sharing_code: library.sharing_code)


      expect(page).to have_content default_invitation
      expect(page.text).to match Regexp.new(library_join_path)

      fill_in "Invitation", with: "A different invitation"

      # TODO: This copies the contents of the invitation to the clipboard. Turns out that this is a huge pain to test
      # since Capybara, Selenium, et. al. don't give good affordances for the Clipboard API. We would love to be able
      # to validate the contents of the clipboard, but don't appear to have good options to grant permission to use the
      # API in automated tests. Making sure we can click the button will have to suffice for now.
      click_button "Copy Invitation"
    end
  end
end
