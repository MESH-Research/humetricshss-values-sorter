# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Landing page" do
  let(:user) { nil }

  before do
    sign_in user if user.present?
    visit root_path
  end

  it "redirects to the main library" do
    expect(page).to have_current_path library_path(Library.main)
  end

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it "redirects to the libraries index" do
      expect(page).to have_current_path libraries_path
    end
  end
end
