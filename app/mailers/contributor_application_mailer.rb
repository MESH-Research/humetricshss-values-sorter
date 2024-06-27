# frozen_string_literal: true

class ContributorApplicationMailer < ApplicationMailer
  def application_received(contributor_application)
    admin_emails = User.admin.pluck(:email)
    return if admin_emails.none?

    @contributor_application = contributor_application
    mail(to: admin_emails, subject: "New Values Sorter contributor application")
  end

  def application_accepted(contributor_application)
    @contributor_application = contributor_application
    mail(
      to: @contributor_application.user.email,
      subject: "Your Values Sorter contributor application has been accepted"
    )
  end

  def application_declined(contributor_application)
    @contributor_application = contributor_application
    mail(
      to: @contributor_application.user.email,
      subject: "Your Values Sorter contributor application has been declined"
    )
  end
end
