# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit

  # TRICKY: ActiveAdmin's auth architecture does not play nice with Pundit verification. This is the solution
  # suggested at https://activeadmin.info/13-authorization-adapter.html#using-the-pundit-adapter. We also add
  # Devise to avoid problems with authorization during login, logout, etc.
  after_action :verify_authorized, except: :index, unless: %i[active_admin_controller? devise_controller?]
  after_action :verify_policy_scoped, only: :index, unless: %i[active_admin_controller? devise_controller?]

  rescue_from Pundit::NotAuthorizedError, with: :resource_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found

  protected

  def active_admin_controller?
    is_a?(ActiveAdmin::BaseController) || is_a?(ActiveAdmin::Devise::SessionsController)
  end

  def access_denied(_cause = nil)
    render file: "#{Rails.root}/public/401.html", layout: false
  end

  def resource_not_found(_cause = nil)
    render file: "#{Rails.root}/public/404.html", layout: false
  end
end
