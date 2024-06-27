# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_sign_up_type, :sanitize_session!, only: %i[new create]
  before_action :configure_sign_up_params, only: [:create]
  before_action :set_sign_up_header, only: [:new]

  def new
    # TRICKY: Devise yields the user before rendering, so we can decorate the User instance with an attribute then,
    # which allows Simple Form to use it transparently
    super do |user|
      contributor_sign_up_decoration!(user)
    end
  end

  def create
    # TRICKY: We also require this decoration if we fail a validation and need to re-render the new page
    super do |user|
      contributor_sign_up_decoration!(user)
    end
    session[:show_signup_banner] = true

    # TRICKY: If the user was successfully persisted, delete oauth data; cookie-based session stores are limited
    session.delete("devise.orcid_data") if resource.persisted?
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name email terms_of_service])
  end

  def after_sign_up_path_for(resource)
    default_path = super(resource)

    if contributor_sign_up?
      # TRICKY: We only set this if we care about where we're sending the use. `root_path` is decidedly "don't care"
      session[:after_apply_path] = default_path unless default_path == root_path
      new_contributor_application_path
    else
      default_path
    end
  end

  private

  def set_sign_up_type
    @sign_up_type = if params.dig(:user, :sign_up_type) == "email"
      "email"
    elsif session["devise.orcid_data"].present?
      "orcid"
    end
  end

  def set_sign_up_header
    @sign_up_header = case @sign_up_type
                      when "orcid"
                        "Sign up with ORCID"
                      else
                        "Sign up for your account"
    end
  end

  def sanitize_session!
    # TRICKY: Unless we are signing up with OAuth we need to clean up the session. This keeps previous OAuth attempts
    # from polluting our working context, which might interfere with current sign up
    return if @sign_up_type == "orcid"

    session.delete("devise.orcid_data")
  end

  def contributor_sign_up?
    contributor_sign_up_param == "1"
  end

  def contributor_sign_up_param
    param = params.dig(:user, :contributor_sign_up)
    if param.present? && param != "0"
      "1"
    else
      "0"
    end
  end

  def contributor_sign_up_decoration!(user)
    class << user
      attr_accessor :contributor_sign_up
    end

    user.contributor_sign_up = contributor_sign_up_param if contributor_sign_up?
  end
end
