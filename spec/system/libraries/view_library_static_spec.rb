# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The library page" do
  let(:user) { nil }
  let(:library) { nil }
  let(:path) { library_path(library) }

  before do
    sign_in user if user.present?
    visit path
  end

  context "when viewing the main library" do
    let(:library) { Library.main }

    context "when not logged in" do
      it "shows the library" do
        expect(page).to have_content "Live your values. Transform the academy."
      end

      it "shows the library", mobile: true do
        expect(page).to have_content "Live your values.\nTransform the academy."
      end

      it_behaves_like "it shows the membership calls-to-action for", :anonymous_user
    end

    context "when logged in" do
      let(:user) { create(:user) }

      it_behaves_like "it shows the membership calls-to-action for", :member

      context "when the user is a contributor" do
        let(:user) { create(:user, role: :contributor) }

        it_behaves_like "it shows the membership calls-to-action for", :contributor
      end
    end
  end

  context "when viewing a user's library" do
    let(:library_owner) { create(:user, first_name: "Library", last_name: "Owner") }
    let(:library) { library_owner.library }

    context "when not logged in" do
      it_behaves_like "it shows a 404 page"
    end

    context "when the library's owner is logged in" do
      let(:user) { library_owner }

      it "shows the library and its edit link" do
        expect(page).to have_content "My Library"
        expect(page).to have_link "Manage Library", href: edit_library_path(library)
      end

      it_behaves_like "it shows the membership calls-to-action for", :member

      context "when the library's owner is a contributor" do
        let(:library_owner) { create(:user, role: :contributor) }

        it_behaves_like "it shows the membership calls-to-action for", :contributor
      end
    end

    context "when another user is logged in" do
      let(:user) { create(:user) }

      it_behaves_like "it shows a 404 page"

      context "when the logged in user is a guest of the library" do
        let(:user) { create(:library_guest, library: library).guest }

        it "shows the library, but not its edit link" do
          expect(page).to have_content "Library Owner's Library"
          expect(page).not_to have_link "Manage Library", href: edit_library_path(library)
        end

        it_behaves_like "it shows the membership calls-to-action for", :member

        context "when the library's owner is a contributor" do
          let(:user) do
            create(:user, role: :contributor).tap do |user|
              create(:library_guest, library: library, guest: user)
            end
          end

          it_behaves_like "it shows the membership calls-to-action for", :contributor
        end
      end
    end
  end
end
