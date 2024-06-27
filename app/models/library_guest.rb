# frozen_string_literal: true

class LibraryGuest < ApplicationRecord
  belongs_to :library
  belongs_to :guest, class_name: "User"

  has_one :owner, through: :library

  validates :guest, uniqueness: { scope: :library, message: "has already joined this library" }
  validate :guest_is_not_library_owner

  private

  def guest_is_not_library_owner
    errors.add(:guest, "must not be the library's owner") if owner == guest
  end
end
