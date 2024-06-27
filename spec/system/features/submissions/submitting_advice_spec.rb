# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Submitting advice" do
  let(:user) { nil }
  let(:library) { create(:user, library_owner_role, first_name: "Connie", last_name: "Tribute").library }
  let(:library_owner_role) { :member }
  let(:activity) { create(:activity, library: library, name: "user activity") }
  let(:value) { create(:value, library: library, name: "user value") }
  let(:advice) { create(:advice, library: library, activity: activity, value: value, text: "Here is some advice") }
  let!(:admins) { create_list(:user, 2, role: :admin) }
  let!(:published_activity) { create(:activity, name: "published activity") }

  before do
    sign_in user if user.present?
    visit new_library_advice_advice_submission_path(library, advice)
  end

  it_behaves_like "it shows a 404 page"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 404 page"
  end

  context "when the library owner is logged in" do
    let(:user) { library.owner }

    it_behaves_like "it shows a 404 page"

    context "when the owner has contributor status" do
      let(:library_owner_role) { :contributor }

      it "allows the user to submit advice and notifies site admins" do
        expect(page).to have_content "Submit advice to be published in HuMetricsHSS library"

        [
          { id: "advice_submission_custom_activity", value: "user activity" },
          { id: "advice_submission_custom_value", value: "user value" },
          { id: "advice_submission_text", value: "Here is some advice" },
          { id: "advice_submission_author_name", value: "Connie Tribute" }
        ].each do |id:, value:|
          element = page.find_by_id(id)
          expect(element).to have_attributes(value: value)
        end

        select "published activity", from: "advice_submission_published_activity"
        fill_in "Value", with: "altered value"
        fill_in "Text", with: "Here is some altered advice"
        check "Do not display my name publicly"

        expect { click_button "Submit" }.to change { advice.reload.submission }.from(nil).to(an_instance_of(AdviceSubmission))

        expect(advice.submission).to have_attributes(
          custom_activity: "user activity",
          published_activity: published_activity,
          custom_value: "altered value",
          published_value: nil,
          text: "Here is some altered advice",
          author_name: ""
        )

        expect(page).to have_content "Manage My Library"
        expect(page).to have_content "Here is some advice"
        expect(page).not_to have_link href: new_library_advice_advice_submission_path(library, advice)

        submission_mail = AdviceSubmissionMailer.deliveries.last
        expect(submission_mail).to have_attributes(
          recipients: a_collection_containing_exactly(*admins.map(&:email)),
          subject: "New Values Sorter advice submission"
        )
        email_content = Capybara.string submission_mail.html_part.body.raw_source
        view_submission_path = admin_advice_submission_path(advice.submission)
        expect(email_content).to have_link "Review Content", href: Regexp.new(view_submission_path)
      end
    end
  end
end
