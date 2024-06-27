# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "it displays the advice details" do
  context "when accessed from a desktop device" do
    it "displays the advice content and a link back to the advice index" do
      expect(page).to have_link "Back", href: library_advice_index_path(advice.library, params)

      expect(page).to have_content <<~TEXT
        Putting on an exhibit Community
        Here is some advice
        Always, ALWAYS read the instruction manual
        It contains very important information
      TEXT
    end
  end

  context "when accessed from a mobile device", :mobile do
    it "displays the advice content and a link back to the advice index" do
      expect(page).to have_link "Back", href: library_advice_index_path(advice.library, params)

      expect(page).to have_content <<~TEXT
        Putting on an exhibit
        Community
        Here is some advice
        Always, ALWAYS read the instruction manual
        It contains very important information
      TEXT
    end
  end
end

RSpec.shared_examples "it does not show draft" do
  it "Hides unpublished advice" do
    visit library_advice_path(library, draft, params)
    expect(page).to have_no_content("This is a draft")
  end
end

RSpec.describe "The advice page" do
  let(:user) { nil }
  let(:library) { nil }
  let!(:activity) { create(:activity, library: library, name: "putting on an exhibit") }
  let!(:value) { create(:value, library: library, name: "community") }
  let!(:advice) { create(:advice, library: library, activity: activity, value: value, text: "Here is some advice", details: details) }
  let!(:draft) { create(:advice, :draft, library: library, activity: activity, value: value) }
  let(:details) { "<p>Always, ALWAYS read the instruction manual</p><p>It contains very important information</p>" }
  let(:params) { { activity_ids: [activity.id], outer_category: :value } }

  before do
    sign_in user if user.present?
    visit library_advice_path(library, advice, params)
  end

  context "when the advice is in the main library" do
    let(:library) { Library.main }

    context "when not logged in" do
      let(:user) { nil }

      it_behaves_like "it displays the advice details"
      it_behaves_like "it does not show draft"
    end

    context "when a user is logged in" do
      let(:user) { create(:user) }

      it_behaves_like "it displays the advice details"
      it_behaves_like "it does not show draft"
    end
  end

  context "when the advice is in a user's library" do
    let(:library) { create(:user).library }

    context "when not logged in" do
      let(:user) { nil }

      it_behaves_like "it shows a 404 page"
    end

    context "when the advice's owner is logged in" do
      let(:user) { advice.owner }

      it_behaves_like "it displays the advice details"
      it_behaves_like "it does not show draft"
    end

    context "when another user is logged in" do
      let(:user) { create(:user) }

      it_behaves_like "it shows a 404 page"

      context "when the logged in user is a guest of the library" do
        let(:user) { create(:library_guest, library: library).guest }

        it_behaves_like "it displays the advice details"
        it_behaves_like "it does not show draft"
      end
    end
  end
end
