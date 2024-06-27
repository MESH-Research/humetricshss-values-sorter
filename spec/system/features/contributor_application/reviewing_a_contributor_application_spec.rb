# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reviewing a contributor application" do
  let(:user) { nil }
  let(:contributor_application) { create(:contributor_application) }

  before do
    sign_in user if user.present?
    visit admin_contributor_application_path(contributor_application)
  end

  it_behaves_like "it redirects to sign in"

  context "when a user is logged in" do
    let(:user) { create(:user) }

    it_behaves_like "it shows a 401 page"
  end

  context "when an admin is logged in" do
    let(:user) { create(:user, role: :admin) }

    it "allows them to accept the application and sends an email to the applicant" do
      expect(page).to have_content "Contributor Application Details"

      expect(page).to have_content "Status Applied"
      expect do
        click_link "Accept", href: accept_admin_contributor_application_path(contributor_application)
        expect(page).to have_content "Status Accepted"
      end.to change { ContributorApplicationMailer.deliveries.size }.by(1)

      accept_mail = ContributorApplicationMailer.deliveries.last
      expect(accept_mail).to have_attributes(
        recipients: a_collection_containing_exactly(contributor_application.user.email),
        subject: "Your Values Sorter contributor application has been accepted"
      )
    end

    it "allows them to decline the application and sends an email to the applicant" do
      expect(page).to have_content "Contributor Application Details"

      expect(page).to have_content "Status Applied"
      expect do
        accept_prompt do
          click_link "Decline", href: decline_admin_contributor_application_path(contributor_application)
        end
        expect(page).to have_content "Status Declined"
      end.to change { ContributorApplicationMailer.deliveries.size }.by(1)

      decline_mail = ContributorApplicationMailer.deliveries.last
      expect(decline_mail).to have_attributes(
        recipients: a_collection_containing_exactly(contributor_application.user.email),
        subject: "Your Values Sorter contributor application has been declined"
      )
    end
  end
end
