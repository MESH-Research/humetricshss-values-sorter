# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The library edit page" do
  let(:library) { create(:user).library }
  let(:user) { nil }
  let(:activity) { create(:activity, library: library, name: "an activity") }
  let(:value) { create(:value, library: library, name: "a value") }
  let!(:advice) { create(:advice, library: library, activity: activity, value: value, text: "Here is some advice") }
  let(:other_activity) { other_advice.activity }
  let(:other_value) { other_advice.value }
  let!(:other_advice) { create(:advice) }

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

    it "shows the library managment page with the expected content" do
      expect(page).to have_content "Manage My Library"

      # 'add new' links
      expect(page).to have_link "+ Add New Activity", href: new_library_activity_path(library)
      expect(page).to have_link "+ Add New Value", href: new_library_value_path(library)
      expect(page).to have_link "+ Add New Advice", href: new_library_advice_path(library)
      expect(page).to have_link "+ Invite Guest", href: new_library_library_guest_path(library)

      # owned content
      expect(page).to have_content "an activity"
      expect(page).to have_link href: edit_library_activity_path(library, activity)
      expect(page).to have_content "a value"
      expect(page).to have_link href: edit_library_value_path(library, value)
      expect(page).to have_content "Here is some advice"
      expect(page).not_to have_link href: new_library_advice_advice_submission_path(library, advice)
      expect(page).to have_link href: edit_library_advice_path(library, advice)

      # unowned content
      expect(page).not_to have_content other_activity.name
      expect(page).not_to have_content other_value.name
      expect(page).not_to have_content other_advice.text
    end

    context "when the library owner has contributor status" do
      before do
        library.owner.update!(role: :contributor)
        page.refresh
      end

      it "shows a submission link next to advice" do
        expect(page).to have_link href: new_library_advice_advice_submission_path(library, advice)
      end
    end
  end
end
