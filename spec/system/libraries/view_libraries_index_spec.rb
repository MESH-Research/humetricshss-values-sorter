# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The library index page" do
  let(:user) { nil }
  let(:link_grid) { page.find_by_id("library-link-grid") }

  before do
    sign_in user if user.present?
    visit libraries_path
  end

  it "shows a link to the HuMetricsHSS public library" do
    expect(link_grid.all("a")).to have_attributes size: 1
    expect(link_grid).to have_link "HuMetricsHSS Published Library", href: library_path(Library.main)
  end

  it_behaves_like "it shows the membership calls-to-action for", :anonymous_user

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it "shows a link to the HuMetricsHSS public library and the user's library" do
      expect(link_grid.all("a")).to have_attributes size: 2
      expect(link_grid).to have_link "HuMetricsHSS Published Library", href: library_path(Library.main)
      expect(link_grid).to have_link "My Library", href: library_path(user.library)
    end

    it_behaves_like "it shows the membership calls-to-action for", :member

    context "when a user is a guest of another user's library" do
      let(:shared_library) { create(:user, first_name: "Sherry", last_name: "Shareperson").library }
      let(:user) { create(:library_guest, library: shared_library).guest }

      it "shows a link to the HuMetricsHSS public library, the user's library, and the shared library" do
        expect(link_grid.all("a")).to have_attributes size: 3
        expect(link_grid).to have_link "HuMetricsHSS Published Library", href: library_path(Library.main)
        expect(link_grid).to have_link "My Library", href: library_path(user.library)
        expect(link_grid).to have_link "Sherry Shareperson's Library", href: library_path(shared_library)
      end
    end

    context "when the user has contributor status" do
      let(:user) { create(:user, role: :contributor) }

      it_behaves_like "it shows the membership calls-to-action for", :contributor
    end
  end
end
