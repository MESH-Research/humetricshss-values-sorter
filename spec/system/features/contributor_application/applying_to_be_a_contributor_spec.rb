# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Applying to be a contributor" do
  let(:user) { nil }

  before do
    sign_in user if user.present?
    visit new_contributor_application_path
  end

  it_behaves_like "it shows a 404 page"

  context "when a user is logged in" do
    let(:user) { create(:user) }
    let!(:admins) { create_list(:user, 2, role: :admin) }

    it "allows the user to apply and notifies site admins" do
      expect(page).to have_content "Become a contributor"

      fill_in "contributor_application_discovery", with: "I discovered the application via referral"
      fill_in "contributor_application_interest", with: "I want to help make academia more accessible"
      fill_in "contributor_application_perspective", with: "I am a professor at Kickass University"

      expect { click_button "Apply to be a contributor" }.to change { ContributorApplicationMailer.deliveries.size }.from(0).to(1)
      expect(page).to have_content "Thank you for applying to be a HuMetrics contributor!"

      application_mail = ContributorApplicationMailer.deliveries.first
      expect(application_mail).to have_attributes(
        recipients: a_collection_containing_exactly(*admins.map(&:email)),
        subject: "New Values Sorter contributor application"
      )
      email_content = Capybara.string application_mail.html_part.body.raw_source
      view_application_path = admin_contributor_application_path(user.reload.contributor_application)
      expect(email_content).to have_link "View Application", href: Regexp.new(view_application_path)
    end

    context "when the user already has a contributor application" do
      let!(:contributor_application) { create(:contributor_application, user: user) }

      it "redirects to the current application" do
        # TRICKY: The visit in the before hook is prior to the application being created - we need to visit again to
        # trigger the expected redirect
        visit new_contributor_application_path
        expect(page).to have_current_path contributor_application_path(contributor_application)
      end
    end
  end
end
