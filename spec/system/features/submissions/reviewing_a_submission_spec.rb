# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reviewing a submission" do
  let(:user) { nil }

  let(:submitter) { create(:user, :contributor, first_name: "Connie", last_name: "Tribute") }
  let(:source_advice) { create(:advice, library: submitter.library) }
  let(:submission) do
    create(
      :advice_submission,
      source_advice: source_advice,
      custom_activity: "user activity",
      published_value: published_value,
    )
  end
  let!(:published_activity) { create(:activity, name: "published activity") }
  let(:published_value) { create(:value, name: "published value") }

  before do
    sign_in user if user.present?
    visit admin_advice_submission_path(submission)
  end

  it_behaves_like "it redirects to sign in"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 401 page"
  end

  context "when an admin is logged in" do
    let(:user) { create(:user, role: :admin) }

    it "allows them to edit and accept the submission, then sends an email to the applicant" do
      expect(page).to have_content "Advice Submission Details"

      expect(page).to have_content "Status Submitted"

      expect(page).not_to have_link "Accept"
      expect(page).to have_link "Connie Tribute", href: admin_user_path(submitter)
      expect(page).to have_link "+ Add new Activity", href: new_admin_activity_path(activity: { name: "user activity" })
      expect(page).not_to have_link "+ Add new Value"
      expect(page).to have_link "published value", href: admin_value_path(published_value)

      click_link "Edit Advice Submission"

      fill_in "Attribution", with: "Dr. Connie Tribute"
      select "published activity", from: "Published activity"
      fill_in "Text", with: "Admin-edited text"

      click_button "Save changes"

      expect do
        click_link "Accept", href: accept_admin_advice_submission_path(submission)
        expect(page).to have_current_path admin_advice_submissions_path
      end.to change { AdviceSubmissionMailer.deliveries.size }.by(1)

      accept_mail = AdviceSubmissionMailer.deliveries.last
      expect(accept_mail).to have_attributes(
        recipients: a_collection_containing_exactly(submission.submitter.email),
        subject: "Your Values Sorter submission has been accepted"
      )

      created_advice = Advice.order(created_at: :desc).first
      expect(created_advice).to have_attributes(
        attribution: "Dr. Connie Tribute",
        activity: published_activity,
        value: published_value,
        text: "Admin-edited text"
      )
    end

    it "allows them to decline the application and sends an email to the applicant" do
      expect(page).to have_content "Advice Submission Details"

      expect(page).to have_content "Status Submitted"
      expect do
        accept_prompt do
          click_link "Decline", href: decline_admin_advice_submission_path(submission)
        end
        expect(page).to have_current_path admin_advice_submissions_path
      end.to change { AdviceSubmissionMailer.deliveries.size }.by(1)

      decline_mail = AdviceSubmissionMailer.deliveries.last
      expect(decline_mail).to have_attributes(
        recipients: a_collection_containing_exactly(submission.submitter.email),
        subject: "Your Values Sorter submission has been declined"
      )
    end
  end
end
