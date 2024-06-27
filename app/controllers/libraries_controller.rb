# frozen_string_literal: true

class LibrariesController < ApplicationController
  include AdviceHelper, LibraryHelper

  def index
    authorize :library
    @libraries = sort_libraries_for_display(
      policy_scope(Library).includes(:owner),
      current_user: current_user
    )
  end

  def show
    @library = authorize Library.find(params[:id])
    @activities = policy_scope(@library.activities).order(:name)
    @values = policy_scope(@library.values).order(:name)
    @params = advice_filter_params(params)
  end

  def edit
    @library = authorize Library.find(params[:id])

    @activities = policy_scope(@library.activities).order(:name)
    @values = policy_scope(@library.values).order(:name)
    @advice = policy_scope(@library.advice).includes(:activity, :value, :rich_text_details).order(:text)
    @library_guests = policy_scope(@library.library_guests).includes(:guest).order(created_at: :desc)
  end
end
