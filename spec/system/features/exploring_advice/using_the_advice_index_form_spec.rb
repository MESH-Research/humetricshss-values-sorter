# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "it displays the library's advice list" do
  context "when accessed from a desktop device" do
    it "displays the advice content" do
      expect(page).to have_content <<~TEXT
        Creating a syllabus
        Community
        a2-v1 advice text\nMore
        Equity
        a2-v2 advice text
        Putting on an exhibit
        Community
        a1-v1 advice text 1\nMore
        a1-v1 advice text 2\nMore
        a1-v1 advice text 3\nMore
        View more
        Equity
        a1-v2 advice text 1
        a1-v2 advice text 2
        a1-v2 advice text 3
      TEXT
    end

    it "does not display advice from other libraries" do
      expect(page).not_to have_content "other library advice text"
    end

    it "does not display draft advice" do
      expect(page).not_to have_content "This is a draft"
    end

    it "displays details links only for advice with details" do
      # first three and has details == shown
      (activity1_value1_advice[0..2] + activity2_value1_advice).each do |advice|
        expect(page).to have_link "advice-link-#{advice.id}", href: library_advice_path(library, advice, { outer_category: "activity" })
      end

      # not first three or no details == not shown
      (activity1_value1_advice[3..] + activity1_value2_advice + activity2_value2_advice).each do |advice|
        expect(page).not_to have_link "advice-link-#{advice.id}"
      end
    end

    context "when the 'View more' button is clicked" do
      it "shows hidden content and hides the 'View more' button when it is clicked" do
        expect(page).to have_content <<~TEXT
          Putting on an exhibit
          Community
          a1-v1 advice text 1\nMore
          a1-v1 advice text 2\nMore
          a1-v1 advice text 3\nMore
          View more
        TEXT

        page.click_button "View more"

        expect(page).to have_content <<~TEXT
          Putting on an exhibit
          Community
          a1-v1 advice text 1\nMore
          a1-v1 advice text 2\nMore
          a1-v1 advice text 3\nMore
          a1-v1 advice text 4\nMore
        TEXT

        expect(page).not_to have_content "View more"
      end

      it "shows details links for the shown advice" do
        page.click_button "View more"

        activity1_value1_advice[3..].each do |advice|
          expect(page).to have_link "advice-link-#{advice.id}", href: library_advice_path(library, advice, { outer_category: "activity" })
        end
      end
    end

    context "when filter and grouping params are specified" do
      let(:params) { { activity_ids: [activity1.id], outer_category: :value } }

      it "displays the filtered advice content" do
        expect(page).to have_content <<~TEXT
          Community
          Putting on an exhibit
          a1-v1 advice text 1\nMore
          a1-v1 advice text 2\nMore
          a1-v1 advice text 3\nMore
          View more
          Equity
          Putting on an exhibit
          a1-v2 advice text 1
          a1-v2 advice text 2
          a1-v2 advice text 3
        TEXT
      end

      it "displays details links only for filtered advice with details" do
        # first three and has details == shown
        activity1_value1_advice[0..2].each do |advice|
          expect(page).to have_link "advice-link-#{advice.id}", href: library_advice_path(library, advice, params)
        end

        # not first three or no details == not shown
        (activity1_value1_advice[3..] + activity1_value2_advice + activity2_value1_advice + activity2_value2_advice).each do |advice|
          expect(page).not_to have_link "advice-link-#{advice.id}"
        end
      end
    end
  end

  context "when accessed from a mobile device", :mobile do
    it "displays the advice content" do
      expect(page).to have_content <<~TEXT
        Creating a syllabus
        Community
        a2-v1 advice text
        Equity
        a2-v2 advice text
        Putting on an exhibit
        Community
        a1-v1 advice text 1
        a1-v1 advice text 2
        a1-v1 advice text 3
        View more
        Equity
        a1-v2 advice text 1
        a1-v2 advice text 2
        a1-v2 advice text 3
      TEXT
    end

    it "does not display advice from other libraries" do
      expect(page).not_to have_content "other library advice text"
    end

    it "displays details links only for advice with details" do
      # first three and has details == shown
      (activity1_value1_advice[0..2] + activity2_value1_advice).each do |advice|
        expect(page).to have_link "advice-link-#{advice.id}", href: library_advice_path(library, advice, { outer_category: "activity" })
      end

      # not first three or no details == not shown
      (activity1_value1_advice[3..] + activity1_value2_advice + activity2_value2_advice).each do |advice|
        expect(page).not_to have_link "advice-link-#{advice.id}"
      end
    end

    context "when the 'View more' button is clicked" do
      it "shows hidden content and hides the 'View more' button when it is clicked" do
        expect(page).to have_content <<~TEXT
          Putting on an exhibit
          Community
          a1-v1 advice text 1
          a1-v1 advice text 2
          a1-v1 advice text 3
          View more
        TEXT

        page.click_button "View more"

        expect(page).to have_content <<~TEXT
          Putting on an exhibit
          Community
          a1-v1 advice text 1
          a1-v1 advice text 2
          a1-v1 advice text 3
          a1-v1 advice text 4
        TEXT

        expect(page).not_to have_content "View more"
      end

      it "shows details links for the shown advice" do
        page.click_button "View more"

        activity1_value1_advice[3..].each do |advice|
          expect(page).to have_link "advice-link-#{advice.id}", href: library_advice_path(library, advice, { outer_category: "activity" })
        end
      end
    end

    context "when filter and grouping params are specified" do
      let(:params) { { activity_ids: [activity1.id], outer_category: :value } }

      it "displays the filtered advice content" do
        expect(page).to have_content <<~TEXT
          Community
          Putting on an exhibit
          a1-v1 advice text 1
          a1-v1 advice text 2
          a1-v1 advice text 3
          View more
          Equity
          Putting on an exhibit
          a1-v2 advice text 1
          a1-v2 advice text 2
          a1-v2 advice text 3
        TEXT
      end

      it "displays details links only for filtered advice with details" do
        # first three and has details == shown
        activity1_value1_advice[0..2].each do |advice|
          expect(page).to have_link "advice-link-#{advice.id}", href: library_advice_path(library, advice, params)
        end

        # not first three or no details == not shown
        (activity1_value1_advice[3..] + activity1_value2_advice + activity2_value1_advice + activity2_value2_advice).each do |advice|
          expect(page).not_to have_link "advice-link-#{advice.id}"
        end
      end
    end
  end
end

RSpec.describe "Using the advice index page form" do
  let(:path) { nil }
  let(:user) { nil }
  let!(:library) { nil }
  let!(:activity1) { create(:activity, library: library, name: "putting on an exhibit") }
  let!(:activity2) { create(:activity, library: library, name: "creating a syllabus") }
  let!(:value1) { create(:value, library: library, name: "community") }
  let!(:value2) { create(:value, library: library, name: "equity") }

  let!(:activity1_value1_advice) do
    Array.new(4) do |i|
      create(:advice, library: library, activity: activity1, value: value1, text: "a1-v1 advice text #{i + 1}", details: "present")
    end
  end
  let!(:activity1_value2_advice) do
    Array.new(3) do |i|
      create(:advice, library: library, activity: activity1, value: value2, text: "a1-v2 advice text #{i + 1}", details: nil)
    end
  end
  let!(:activity2_value1_advice) { [create(:advice, library: library, activity: activity2, value: value1, text: "a2-v1 advice text", details: "present")] }
  let!(:activity2_value2_advice) { [create(:advice, library: library, activity: activity2, value: value2, text: "a2-v2 advice text", details: nil)] }

  let!(:other_library) { create(:user).library }
  let!(:other_library_advice) { create(:advice, library: other_library, text: "other library advice text") }
  let!(:draft) { create(:advice, :draft, library: library) }

  let(:params) { {} }

  before do
    sign_in user if user.present?
    visit path
  end

  context "when accessing the main library" do
    let(:path) { main_library_advice_index_path(params) }
    let(:library) { Library.main }

    context "when not logged in" do
      let(:user) { nil }

      it_behaves_like "it displays the library's advice list"
    end

    context "when a user is logged in" do
      let(:user) { create(:user) }

      it_behaves_like "it displays the library's advice list"
    end
  end

  context "when accessing a user's library" do
    let(:path) { library_advice_index_path(library, params) }
    let(:library) { create(:user).library }

    context "when not logged in" do
      it_behaves_like "it shows a 404 page"
    end

    context "when another user is logged in" do
      let(:user) { create(:user) }

      it_behaves_like "it shows a 404 page"

      context "when the logged in user is a guest of the library" do
        let(:user) { create(:library_guest, library: library).guest }

        it_behaves_like "it displays the library's advice list"
      end
    end

    context "when the library's owner is logged in" do
      let(:user) { library.owner }

      it_behaves_like "it displays the library's advice list"
    end
  end
end
