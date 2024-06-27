# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :library
  has_one :owner, through: :library
  has_many :advice, dependent: :restrict_with_error

  validates :name, presence: true
end
