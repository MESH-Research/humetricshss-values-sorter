# frozen_string_literal: true

class AdviceSubmission < ApplicationRecord
  class NonpendingSubmissionError < StandardError; end
  class UnpublishableSubmissionError < StandardError; end

  ANONYMOUS_ATTRIBUTION = "a HuMetrics Contributor"

  # TRICKY: In practice we will never want #source_advice to be nil, but this keeps us from needing to destroy the
  # AdviceSubmission when e.g. a User destroys the Advice used to create it
  belongs_to :source_advice, class_name: "Advice", optional: true
  has_one :source_library, through: :source_advice, source: :library
  has_one :submitter, through: :source_library, source: :owner

  belongs_to :published_advice, class_name: "Advice", optional: true
  has_rich_text :submitted_details
  has_rich_text :details

  belongs_to :published_activity, class_name: "Activity", optional: true
  belongs_to :published_value, class_name: "Value", optional: true

  enum status: { declined: -1, pending: 0, accepted: 1 }

  validates :text, :status, presence: true
  validate :not_already_submitted, if: -> { source_advice.present? }
  validate :published_to_main_library, if: -> { published_advice.present? }

  validate :activity_in_main_library, unless: :uses_custom_activity?
  validates :custom_activity, presence: true, if: :uses_custom_activity?

  validate :value_in_main_library, unless: :uses_custom_value?
  validates :custom_value, presence: true, if: :uses_custom_value?

  before_create :copy_submitted_attributes
  after_create_commit :notify_submission_received

  def uses_custom_activity?
    published_activity.blank?
  end

  def uses_custom_value?
    published_value.blank?
  end

  def attribution
    return ANONYMOUS_ATTRIBUTION if author_name.blank?

    author_name
  end

  def ready_to_publish?
    build_published_advice unless published_advice.present?

    published_advice.valid?
  end

  def build_published_advice(attributes = {})
    attributes = default_advice_attributes.merge(attributes)
    super(attributes)
  end

  def accept!
    ensure_ready_to_publish!

    with_lock do
      build_published_advice unless published_advice.present?

      published_advice.save!
      update!(status: :accepted)
    end

    AdviceSubmissionMailer.submission_accepted(self).deliver_now
  end

  def decline!
    ensure_pending!

    update!(status: :declined)

    AdviceSubmissionMailer.submission_declined(self).deliver_now
  end

  private

  def ensure_pending!
    return if pending?

    raise NonpendingSubmissionError, "AdviceSubmission has already been #{status}"
  end

  def ensure_ready_to_publish!
    ensure_pending!

    return if ready_to_publish?

    raise UnpublishableSubmissionError, "AdviceSubmission is not in a publishable state"
  end

  def not_already_submitted
    # TRICKY: If this is persisted and has an unchanged source advice id then we are editing an existing submission,
    # so there is no need to panic if a submission exists. We KNOW one exists, in fact: this one.
    return if persisted? && !source_advice_id_changed?

    errors.add(:source_advice, "has already been submitted") if source_advice.submitted?
  end

  def published_to_main_library
    errors.add(:published_advice, "must belong to the main library") unless published_advice&.library&.main?
  end

  def activity_in_main_library
    errors.add(:published_activity, "must belong to the main library") unless published_activity&.library&.main?
  end

  def value_in_main_library
    errors.add(:published_value, "must belong to the main library") unless published_value&.library&.main?
  end

  def copy_submitted_attributes
    self.submitted_text = text
    self.submitted_details = details
  end

  def notify_submission_received
    AdviceSubmissionMailer.submission_received(self)&.deliver_now
  end

  def default_advice_attributes
    {
      library: Library.main,
      attribution: attribution,
      activity: published_activity,
      value: published_value,
      text: text,
      details: details&.body&.to_trix_html
    }
  end
end
