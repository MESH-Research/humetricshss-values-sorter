# frozen_string_literal: true

ActiveAdmin.register ContributorApplication do
  menu false
  actions :all, except: %i[index new create edit update destroy]
  config.batch_actions = false

  show do
    attributes_table do
      row :user
      row :discovery
      row :interest
      row :perspective
      row :status do |contributor_application|
        if contributor_application.pending?
          "Applied #{contributor_application.created_at.strftime("%m/%d/%Y")}"
        else
          "#{contributor_application.status.titleize} #{contributor_application.updated_at.strftime("%m/%d/%Y")}"
        end
      end
    end
  end

  action_item :view, only: :show do
    if contributor_application.pending?
      link_to "Accept", accept_admin_contributor_application_path(contributor_application), method: :put
    end
  end

  action_item :view, only: :show do
    if contributor_application.pending?
      link_to "Decline", decline_admin_contributor_application_path(contributor_application), method: :put, "data-confirm": "Are you sure?"
    end
  end

  member_action :accept, method: :put do
    resource.accept!
    redirect_to resource_path, notice: "Application accepted"
  rescue ContributorApplication::NonpendingApplicationError => e
    redirect_to resource_path, alert: e.to_s
  end

  member_action :decline, method: :put do
    resource.decline!
    redirect_to resource_path, notice: "Application declined"
  rescue ContributorApplication::NonpendingApplicationError => e
    redirect_to resource_path, alert: e.to_s
  end
end
