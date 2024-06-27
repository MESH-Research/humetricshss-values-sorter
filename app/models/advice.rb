# frozen_string_literal: true

class Advice < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_text, against: :text, using: { tsearch: { prefix: true } }
  pg_search_scope :search_details, associated_against: {
    rich_text_details: [:body]
  }, using: { tsearch: { prefix: true } }

  belongs_to :library
  has_one :owner, through: :library
  belongs_to :activity
  belongs_to :value
  has_rich_text :details

  enum published_state: { draft: 0, published: 1 }

  has_one :submission, dependent: :nullify,
          class_name: "AdviceSubmission", foreign_key: "source_advice_id", inverse_of: :source_advice
  validates :text, presence: true
  validate :activity_library_matches, :value_library_matches

  def submitted?
    AdviceSubmission.where(source_advice: self).any?
  end

  def build_submission(attributes = {})
    attributes = default_submission_attributes.merge(attributes)
    super(attributes)
  end

  private

  def default_submission_attributes
    {
      author_name: owner.full_name,
      custom_activity: activity.name,
      custom_value: value.name,
      text: text,
      details: details&.body&.to_trix_html,
      status: :pending
    }
  end

  def activity_library_matches
    return if activity.blank?

    errors.add(:activity, "must belong to the same library") unless activity.library == library
  end

  def value_library_matches
    return if value.blank?

    errors.add(:value, "must belong to the same library") unless value.library == library
  end
end
