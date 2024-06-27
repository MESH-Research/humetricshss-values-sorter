# frozen_string_literal: true

class AdviceSubmissionMailer < ApplicationMailer
  def submission_received(advice_submission)
    admin_emails = User.admin.pluck(:email)
    return if admin_emails.none?

    @advice_submission = advice_submission
    mail(to: admin_emails, subject: "New Values Sorter advice submission")
  end

  def submission_accepted(advice_submission)
    @advice_submission = advice_submission
    mail(
      to: @advice_submission.submitter.email,
      subject: "Your Values Sorter submission has been accepted"
    )
  end

  def submission_declined(advice_submission)
    @advice_submission = advice_submission
    mail(
      to: @advice_submission.submitter.email,
      subject: "Your Values Sorter submission has been declined"
    )
  end
end
