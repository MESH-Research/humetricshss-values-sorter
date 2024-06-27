# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  skip_before_action :verify_authenticity_token, only: :orcid

  def orcid
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.present?
      sign_in_and_redirect @user, event: :authentication
    else
      # TRICKY: Delete useless data; cookie-based session stores are limited
      session["devise.orcid_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_path
    end
  end

  def failure
    alert = "Couldn't sign in with ORCID"
    alert += ": #{params[:error_description]}" if params[:error_description].present?

    redirect_to root_path, alert: alert
  end
end
