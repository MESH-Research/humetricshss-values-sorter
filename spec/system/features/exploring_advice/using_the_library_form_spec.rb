# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "it displays the library page" do
  it "contains the form inputs in the default state" do
    expect(page).to have_field("outer_category", type: :hidden, with: "activity")

    expect(page).to have_selector("label", text: "Putting on an exhibit")
    expect(page).to have_unchecked_field("Putting on an exhibit", visible: false)
    expect(page).to have_selector("label", text: "Creating a syllabus")
    expect(page).to have_unchecked_field("Creating a syllabus", visible: false)

    expect(page).to have_selector("label", text: "Community")
    expect(page).to have_unchecked_field("Community", visible: false)
    expect(page).to have_selector("label", text: "Equity")
    expect(page).to have_unchecked_field("Equity", visible: false)
  end

  it "does not show form inputs for other libraries' activities or values" do
    expect(page).not_to have_selector("label", text: "Activity from another library")
    expect(page).not_to have_unchecked_field("Activity from another library", visible: false)

    expect(page).not_to have_selector("label", text: "Value from another library")
    expect(page).not_to have_unchecked_field("Value from another library", visible: false)
  end

  context "when params are specified" do
    let(:params) { { activity_ids: [activity1.id], value_ids: [value2.id], outer_category: "value" } }

    it "contains the form inputs in the expected state" do
      expect(page).to have_field("outer_category", type: :hidden, with: "value")

      expect(page).to have_selector("label", text: "Putting on an exhibit")
      expect(page).to have_checked_field("Putting on an exhibit", visible: false)
      expect(page).to have_selector("label", text: "Creating a syllabus")
      expect(page).to have_unchecked_field("Creating a syllabus", visible: false)

      expect(page).to have_selector("label", text: "Community")
      expect(page).to have_unchecked_field("Community", visible: false)
      expect(page).to have_selector("label", text: "Equity")
      expect(page).to have_checked_field("Equity", visible: false)
    end
  end

  it "allows users to change the filter inputs" do
    expect(page).to have_unchecked_field("Creating a syllabus", visible: false)
    expect(page).to have_unchecked_field("Community", visible: false)

    page.find("label", text: "Creating a syllabus").click
    page.find("label", text: "Community").click

    expect(page).to have_checked_field("Creating a syllabus", visible: false)
    expect(page).to have_checked_field("Community", visible: false)
  end

  it "does not allow form submission unless a filter selection is made" do
    button = page.find_button "View advice", disabled: true
    expect { page.find("label", text: "Putting on an exhibit").click }.to change(button, :disabled?).from(true).to(false)
    expect { page.find("label", text: "Equity").click }.not_to change(button, :disabled?)
    expect { page.find("label", text: "Putting on an exhibit").click }.not_to change(button, :disabled?)
    expect { page.find("label", text: "Equity").click }.to change(button, :disabled?).from(false).to(true)
  end

  it "sends the user to the filtered advice list" do
    page.find("label", text: "Putting on an exhibit").click
    page.find("label", text: "Community").click
    page.find("label", text: "Equity").click

    click_button "View advice"

    # We need to ensure navigation has completed before we can examine the query string
    expect(page).to have_current_path(/\/advice/)

    uri = URI.parse(current_url)
    query_params = CGI.parse(uri.query)
    expect(query_params).to include(
      "activity_ids[]" => ["", activity1.id],
      "value_ids[]" => ["", value1.id, value2.id],
      "outer_category" => ["activity"]
    )
  end
end

RSpec.describe "Using the library page form" do
  let(:user) { nil }
  let(:library) { nil }
  let!(:activity1) { create(:activity, library: library, name: "putting on an exhibit") }
  let!(:activity2) { create(:activity, library: library, name: "creating a syllabus") }
  let!(:value1) { create(:value, library: library, name: "community") }
  let!(:value2) { create(:value, library: library, name: "equity") }
  let(:other_library) { create(:user).library }
  let!(:other_library_activity) { create(:activity, library: other_library, name: "activity from another library") }
  let!(:other_library_value) { create(:value, library: other_library, name: "value from another library") }

  let(:params) { {} }

  before do
    sign_in user if user.present?
    visit library_path(library, params)
  end

  context "when accessing the main library" do
    let(:library) { Library.main }

    context "when not logged in" do
      let(:user) { nil }

      it_behaves_like "it displays the library page"
    end

    context "when a user is logged in" do
      let(:user) { create(:user) }

      it_behaves_like "it displays the library page"
    end
  end

  context "when accessing a user's library" do
    let(:library) { create(:user).library }

    context "when not logged in" do
      it_behaves_like "it shows a 404 page"
    end

    context "when another user is logged in" do
      let(:user) { create(:user) }

      it_behaves_like "it shows a 404 page"

      context "when the logged in user is a guest of the library" do
        let(:user) { create(:library_guest, library: library).guest }

        it_behaves_like "it displays the library page"
      end
    end

    context "when the library's owner is logged in" do
      let(:user) { library.owner }

      it_behaves_like "it displays the library page"
    end
  end
end
