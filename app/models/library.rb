# frozen_string_literal: true

class Library < ApplicationRecord
  MAIN_LIBRARY_ID = "9bd2ecee-dfc8-46bc-8184-c0d2ece85080"

  # TRICKY: We raise an error when trying to destroy activities/values which still have advice, as it is not obvious
  # to the user that this would orphan/destroy the advice. It is obvious what will happen when a library is destroyed,
  # though, and we don't want those errors to keep us from doing so. When a library is destroyed this callback prepends
  # the destruction of each activity/value's advice to the transaction, ensuring that all library members are destroyed
  # without raising
  before_destroy :destroy_related_advice, prepend: true
  before_validation :reroll_sharing_code, if: -> { sharing_code.blank? }

  belongs_to :owner, class_name: "User", optional: true
  has_many :activities, dependent: :destroy
  has_many :values, dependent: :destroy
  has_many :advice, dependent: :destroy
  has_many :library_guests, dependent: :destroy
  has_many :guests, through: :library_guests

  validates :sharing_code, presence: true
  validates :owner, absence: true, if: :main?
  validates :owner, presence: true, unless: :main?

  # TRICKY: Using `unless: -> { main? }` below would also avoid issues with the main library having a null owner. If
  # for some reason we try to create a different library with no owner, however, then we get two messages: "can't be
  # blank", and "has already been taken", the latter being a false-positive. We don't care that we already have a
  # library with a nonunique, null owner_id; the issue is that only one library is allowed to - the main library - and
  # that's why we're getting "can't be blank". `unless: -> { owner.blank? }` limits the error message to "can't be
  # blank".
  validates :owner, uniqueness: true, unless: -> { owner.blank? }

  def self.main
    find(MAIN_LIBRARY_ID)
  end

  def main?
    id == MAIN_LIBRARY_ID
  end

  def reroll_sharing_code
    self.sharing_code = SecureRandom.uuid
  end

  def reroll_sharing_code!
    reroll_sharing_code
    save!
  end

  private

  def destroy_related_advice
    activities.each { |activity| activity.advice.destroy_all }
    values.each { |value| value.advice.destroy_all }
  end
end
