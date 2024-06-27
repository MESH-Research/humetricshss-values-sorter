# frozen_string_literal: true

class StaticController < ApplicationController
  include AdviceHelper

  before_action :skip_authorization

  def landing
    if user_signed_in?
      redirect_to libraries_path
    else
      redirect_to library_path(Library.main)
    end
  end

  def code_of_conduct
  end
end
