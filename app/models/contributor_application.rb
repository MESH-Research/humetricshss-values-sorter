# frozen_string_literal: true

class ContributorApplication < ApplicationRecord
  class NonpendingApplicationError < StandardError; end

  belongs_to :user

  enum status: { declined: -1, pending: 0, accepted: 1 }

  validates :discovery, :interest, :perspective, :status, presence: true
  validates :user, uniqueness: true

  after_create_commit :notify_application_received

  def accept!
    ensure_pending!

    user.with_lock do
      lock!
      # TRICKY: If the user has admin permissions this should not unexpectedly revoke them
      user.update!(role: :contributor) unless user.admin?
      update!(status: :accepted)
    end

    ContributorApplicationMailer.application_accepted(self).deliver_now
  end

  def decline!
    ensure_pending!

    update!(status: :declined)

    ContributorApplicationMailer.application_declined(self).deliver_now
  end

  private

  def ensure_pending!
    return if pending?

    raise NonpendingApplicationError, "ContributorApplication has already been #{status}"
  end

  def notify_application_received
    ContributorApplicationMailer.application_received(self)&.deliver_now
  end
end
