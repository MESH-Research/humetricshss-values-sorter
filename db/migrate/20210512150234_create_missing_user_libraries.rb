# frozen_string_literal: true

class CreateMissingUserLibraries < ActiveRecord::Migration[6.1]
  class User < ApplicationRecord
    has_one :library
  end

  class Library < ApplicationRecord
    belongs_to :user, optional: true
  end

  def up
    User.find_each do |user|
      next if user.library.present?

      user.create_library!
    end
  end
end
