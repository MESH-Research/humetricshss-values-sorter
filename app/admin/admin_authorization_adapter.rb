# frozen_string_literal: true

class AdminAuthorizationAdapter < ActiveAdmin::AuthorizationAdapter
  def authorized?(_action, _subject = nil)
    user.admin?
  end
end
