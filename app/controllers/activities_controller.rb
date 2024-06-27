# frozen_string_literal: true

class ActivitiesController < ApplicationController
  before_action :set_library
  before_action :build_activity, only: %i[new create]
  before_action :set_activity, only: %i[edit update destroy]

  def new
  end

  def create
    if @activity.save
      redirect_to edit_library_path(@library)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @activity.update(activity_params)
      redirect_to edit_library_path(@library)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @activity.destroy
      redirect_to edit_library_path(@library)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_library
    @library = policy_scope(Library).find(params[:library_id])
  end

  def build_activity
    @activity = authorize @library.activities.build(activity_params)
  end

  def set_activity
    @activity = authorize library_activities.find(params[:id])
  end

  def library_activities
    policy_scope(Activity).where(library: @library)
  end

  def activity_params
    params.fetch(:activity, {}).permit(:name)
  end
end
