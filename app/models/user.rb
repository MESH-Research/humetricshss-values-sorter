# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :registerable
  # See db/migrate/20210202172421_devise_create_users.rb for required columns
  devise :database_authenticatable, :recoverable, :registerable, :validatable, :omniauthable, omniauth_providers: %i[orcid]

  # TRICKY: A User ALWAYS has a Library. If we create a user and it doesn't exist yet, then create it. If it exists but
  # hasn't been persisted, then save it
  after_create :create_or_save_library, unless: -> { library&.persisted? }

  has_one :contributor_application, dependent: :destroy

  has_one :library, dependent: :destroy, foreign_key: "owner_id", inverse_of: :owner
  has_many :activities, through: :library
  has_many :values, through: :library
  has_many :advice, through: :library

  has_many :library_guests, dependent: :destroy, foreign_key: "guest_id", inverse_of: :guest
  has_many :shared_libraries, through: :library_guests, source: :library

  enum role: { member: 0, contributor: 1, admin: 2 }

  validates :first_name, :last_name, :role, presence: true
  validates :terms_of_service, acceptance: { allow_nil: false }

  def self.from_omniauth(auth)
    find_by(provider: auth.provider, uid: auth.uid)
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if orcid_data = session.dig("devise.orcid_data")
        # TRICKY: These should always be taken from the session or generated; users should not be able to set these
        user.provider = orcid_data["provider"]
        user.uid = orcid_data["uid"]
        user.password = Devise.friendly_token(20)

        # TRICKY: These should be taken from the session only if they are empty - the user may override them
        user.email = orcid_data.dig("info", "email") if user.email.blank?
        user.first_name = orcid_data.dig("info", "first_name") if user.first_name.blank?
        user.last_name = orcid_data.dig("info", "last_name") if user.last_name.blank?
      end
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def can_contribute?
    contributor? || admin?
  end

  private

  def create_or_save_library
    if library.present?
      library.save!
    else
      create_library!
    end
  end
end
