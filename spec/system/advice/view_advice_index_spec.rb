# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The advice index page" do
  let!(:library) { Library.main }
  let!(:activity1) { create(:activity, library: library, name: "putting on an exhibit") }
  let!(:activity2) { create(:activity, library: library, name: "creating a syllabus") }
  let!(:value1) { create(:value, library: library, name: "community") }
  let!(:value2) { create(:value, library: library, name: "equity") }
  let(:other_library) { create(:user).library }
  let!(:other_library_activity) { create(:activity, library: other_library, name: "activity from another library") }
  let!(:other_library_value) { create(:value, library: other_library, name: "value from another library") }

  let(:params) { {} }

  before { visit library_advice_index_path(library, params) }

  it "contains the advice list controls in the default state" do
    expect(page).to have_selector("label", text: "Putting on an exhibit")
    expect(page).to have_unchecked_field("Putting on an exhibit", visible: false)
    expect(page).to have_selector("label", text: "Creating a syllabus")
    expect(page).to have_unchecked_field("Creating a syllabus", visible: false)

    expect(page).to have_selector("label", text: "Community")
    expect(page).to have_unchecked_field("Community", visible: false)
    expect(page).to have_selector("label", text: "Equity")
    expect(page).to have_unchecked_field("Equity", visible: false)

    expect(page).to have_selector("label", text: "Activity")
    expect(page).to have_checked_field("Activity", visible: false)
    expect(page).to have_selector("label", text: "Value")
    expect(page).to have_unchecked_field("Value", visible: false)
  end

  it "does not show form inputs for other libraries' activities or values" do
    expect(page).not_to have_selector("label", text: "Activity from another library")
    expect(page).not_to have_unchecked_field("Activity from another library", visible: false)

    expect(page).not_to have_selector("label", text: "Value from another library")
    expect(page).not_to have_unchecked_field("Value from another library", visible: false)
  end

  context "when filter and grouping params are specified" do
    let(:params) { { activity_ids: [activity1.id], value_ids: [value2.id], outer_category: :value } }

    it "contains the landing page checkbox filters in the expected state" do
      expect(page).to have_selector("label", text: "Putting on an exhibit")
      expect(page).to have_checked_field("Putting on an exhibit", visible: false)
      expect(page).to have_selector("label", text: "Creating a syllabus")
      expect(page).to have_unchecked_field("Creating a syllabus", visible: false)

      expect(page).to have_selector("label", text: "Community")
      expect(page).to have_unchecked_field("Community", visible: false)
      expect(page).to have_selector("label", text: "Equity")
      expect(page).to have_checked_field("Equity", visible: false)

      expect(page).to have_selector("label", text: "Activity")
      expect(page).to have_unchecked_field("Activity", visible: false)
      expect(page).to have_selector("label", text: "Value")
      expect(page).to have_checked_field("Value", visible: false)
    end

    context "when accessed from a mobile device", :mobile do
      it "shows the correct back link" do
        expect(page).to have_link "Back to selection",
                                  href: library_path(
                                    Library.main,
                                    activity_ids: [activity1.id],
                                    value_ids: [value2.id],
                                    outer_category: "value"
                                  )
      end
    end
  end

  context "when a filter button is clicked" do
    it "loads the page with the filter changed" do
      page.find("label", text: "Putting on an exhibit").click

      expect(page).to have_current_path(/#{activity1.id}/)

      uri = URI.parse(current_url)
      query_params = CGI.parse(uri.query)
      expect(query_params).to include(
        "activity_ids[]" => ["", activity1.id],
        "value_ids[]" => [""],
        "outer_category" => ["", "activity"]
      )
    end
  end

  context "when the grouping toggle is clicked" do
    it "loads the page with the grouping changed" do
      page.find("label", text: "Value").click

      expect(page).to have_current_path(/value/)

      uri = URI.parse(current_url)
      query_params = CGI.parse(uri.query)
      expect(query_params).to include(
        "activity_ids[]" => [""],
        "value_ids[]" => [""],
        "outer_category" => ["", "value"]
      )
    end
  end

  context "when accessed from a mobile device", :mobile do
    it "shows the back link instead of the filters" do
      expect(page).to have_link "Back to selection", href: library_path(Library.main, outer_category: "activity")

      expect(page).not_to have_selector("label", text: "Putting on an exhibit")
      expect(page).not_to have_selector("label", text: "Creating a syllabus")
      expect(page).not_to have_selector("label", text: "Community")
      expect(page).not_to have_selector("label", text: "Equity")

      expect(page).to have_selector("label", text: "Activity")
      expect(page).to have_checked_field("Activity", visible: false)
      expect(page).to have_selector("label", text: "Value")
      expect(page).to have_unchecked_field("Value", visible: false)
    end
  end
end
