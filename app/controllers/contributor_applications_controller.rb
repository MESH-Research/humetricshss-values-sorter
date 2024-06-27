# frozen_string_literal: true

class ContributorApplicationsController < ApplicationController
  def show
    @contributor_application = authorize policy_scope(ContributorApplication).find(params[:id])
  end

  def new
    authorize :contributor_application

    if current_user.contributor_application.present?
      redirect_to current_user.contributor_application
    else
      @contributor_application = current_user.build_contributor_application
    end
  end

  def create
    authorize :contributor_application

    @contributor_application = current_user.build_contributor_application(contributor_application_params)
    if @contributor_application.save
      # TRICKY: If we have a specific redirect path, send the applicant there. If not, show the application
      target = session.delete(:after_apply_path).presence || @contributor_application
      redirect_to target
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contributor_application_params
    params.require(:contributor_application).permit(:discovery, :interest, :perspective)
  end
end
