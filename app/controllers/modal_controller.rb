# frozen_string_literal: true

class ModalController < ApplicationController
  def delete
    skip_authorization
    session.delete(:show_signup_banner)
    head :no_content
  end
end
