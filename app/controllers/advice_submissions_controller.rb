# frozen_string_literal: true

class AdviceSubmissionsController < ApplicationController
  before_action :set_library, :set_advice
  before_action :set_published_activities, :set_published_values, :build_submission, :submission_editing_decoration!, only: %i[new create]

  def new
  end

  def create
    if @submission.save
      redirect_to edit_library_path(@library)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_library
    @library = policy_scope(Library).find(params[:library_id])
  end

  def set_advice
    library_advice = Advice.where(library: @library)
    @advice = policy_scope(library_advice).find(params[:advice_id])
  end

  def set_published_activities
    @published_activities = policy_scope(Library.main.activities).order(:name)
  end

  def set_published_values
    @published_values = policy_scope(Library.main.values).order(:name)
  end

  def build_submission
    @submission = authorize @advice.build_submission(submission_params)
  end

  def submission_params
    submission_params = params.fetch(:advice_submission, {})
                              .permit(:custom_activity,
                                      :published_activity,
                                      :custom_value,
                                      :published_value,
                                      :text,
                                      :details,
                                      :author_name
                                     ).to_h
    submission_params[:published_activity] = @published_activities.find_by(id: submission_params[:published_activity]) if submission_params.key?(:published_activity)
    submission_params[:published_value] = @published_values.find_by(id: submission_params[:published_value]) if submission_params.key?(:published_value)
    submission_params[:author_name] = "" if anonymous_param == "1"
    submission_params
  end

  def submission_editing_decoration!
    class << @submission
      attr_accessor :anonymous

      def anonymous?
        anonymous == "1"
      end
    end

    @submission.anonymous = anonymous_param
  end


  def anonymous_param
    param = params.dig(:advice_submission, :anonymous)
    if param.present? && param != "0"
      "1"
    else
      "0"
    end
  end
end
