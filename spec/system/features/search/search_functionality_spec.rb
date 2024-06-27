# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search Functionality" do
  let!(:user) { create(:user) }
  let!(:library) { create(:user).library }
  let!(:activity1) { create(:activity, library: user.library, name: "Supercalifragilisticexpialidocious") }
  let!(:value1) { create(:value, library: user.library, name: "Petrichor") }
  let!(:advice) do
    create(:advice, library: user.library, activity: activity1, value: value1, text: "test example")
  end

  it "Searches from Navbar" do
    visit root_path
    find(class: "search-input").fill_in(with: "autem")
    find(class: "search-submit").click
    expect(find(class: "search-input").value).to eq "autem"
    expect(page).to have_content "Select activities"
    expect(page).to have_content "Select values"
    expect(page).to have_content "Group by"
  end

  it "Searches from Library Page" do
      visit library_path(Library.main)
      find(class: "search-input").fill_in(with: "autem")
      click_button "View advice"
      expect(find(class: "search-input").value).to eq "autem"
      expect(page).to have_content "Select activities"
      expect(page).to have_content "Select values"
      expect(page).to have_content "Group by"
    end

  it "Searches from Advice Page" do
    visit library_path(Library.main)
    find(class: "search-input").fill_in(with: "autem")
    click_button "View advice"
    expect(page).to have_content "Select activities"
    expect(page).to have_content "Select values"
    expect(page).to have_content "Group by"
    expect(find(class: "search-input").value).to eq "autem"
    find(class: "search-input").fill_in(with: "b")
    find(class: "search-submit").click
    expect(page).to have_content "Select activities"
    expect(page).to have_content "Select values"
    expect(page).to have_content "Group by"
    expect(find(class: "search-input").value).to eq "b"
  end

  it "Searches the right Library" do
    # #User Library
    login_as user
    visit library_path(user.library)
    find(class: "search-input").fill_in(with: "test example")
    find(class: "search-submit").click
    expect(page).to have_content "Supercalifragilisticexpialidocious"
    expect(page).to have_content "Petrichor"
    expect(page).to have_content "test example"

    # #Navbar
    visit root_path
    find(class: "search-input").fill_in(with: "test example")
    find(class: "search-submit").click
    expect(page).to have_no_content "Supercalifragilisticexpialidocious"
    expect(page).to have_no_content "Petrichor"

    # #Main library
    visit library_path(Library.main)
    find(class: "search-input").fill_in(with: "test example")
    find(class: "search-submit").click
    expect(page).to have_no_content "Supercalifragilisticexpialidocious"
    expect(page).to have_no_content "Petrichor"
  end
  context "when accessed from a mobile device", :mobile do
    it "Searches from Navbar" do
      visit root_path
      find(class: "search-input").fill_in(with: "autem")
      find(class: "search-submit").click
      expect(find(class: "search-input").value).to eq "autem"
      expect(page).to have_content "Activity"
      expect(page).to have_content "Value"
    end

    it "Searches from Library Page" do
        visit library_path(Library.main)
        find(class: "search-input").fill_in(with: "autem")
        click_button "View advice"
        expect(find(class: "search-input").value).to eq "autem"
        expect(page).to have_content "Activity"
        expect(page).to have_content "Value"
      end

    it "Searches from Advice Page" do
      visit library_path(Library.main)
      find(class: "search-input").fill_in(with: "autem")
      click_button "View advice"
      expect(page).to have_content "Activity"
      expect(page).to have_content "Value"
      expect(find(class: "search-input").value).to eq "autem"
      find(class: "search-input").fill_in(with: "b")
      find(class: "search-submit").click
      expect(page).to have_content "Activity"
      expect(page).to have_content "Value"
      expect(find(class: "search-input").value).to eq "b"
    end

    it "Searches the right Library" do
      # #User Library
      login_as user
      visit library_path(user.library)
      find(class: "search-input").fill_in(with: "test example")
      find(class: "search-submit").click
      expect(page).to have_content "Supercalifragilisticexpialidocious"
      expect(page).to have_content "Petrichor"
      expect(page).to have_content "test example"

      # #Navbar
      visit root_path
      find(class: "search-input").fill_in(with: "test example")
      find(class: "search-submit").click
      expect(page).to have_no_content "Supercalifragilisticexpialidocious"
      expect(page).to have_no_content "Petrichor"

      # #Main library
      visit library_path(Library.main)
      find(class: "search-input").fill_in(with: "test example")
      find(class: "search-submit").click
      expect(page).to have_no_content "Supercalifragilisticexpialidocious"
      expect(page).to have_no_content "Petrichor"
    end
  end
end
