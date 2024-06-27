# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 1

  permit_params :first_name, :last_name, :email, :password, :password_confirmation, :role

  includes :contributor_application

  index do
    selectable_column
    column :full_name, sortable: :first_name
    column :email
    column :role
    column :contributor_application do |user|
      if user.contributor_application.present?
        link_to(
          "Applied #{user.contributor_application.created_at.strftime("%m/%d/%Y")}",
          admin_contributor_application_path(user.contributor_application)
        )
      end
    end
    column :contributor_status do |user|
      contributor_application = user.contributor_application
      next unless contributor_application.present?

      if contributor_application.pending?
        [
          link_to("Accept", accept_admin_contributor_application_path(contributor_application), method: :put),
          link_to(
            "Decline",
            decline_admin_contributor_application_path(contributor_application),
            method: :put,
            "data-confirm": "Are you sure?"
          )
        ].join(" ").html_safe
      else
        "#{contributor_application.status.titleize} #{contributor_application.updated_at.strftime("%m/%d/%Y")}"
      end
    end
    actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :role
      # TRICKY: Active Admin REALLY wants the row header to be nonempty - `row ""` results in an error
      row " " do
        a "View library content", href: admin_user_advice_index_path(user)
      end
    end
  end

  config.filters = false

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :role, include_blank: false
      f.input :password, required: false, label: "Password (leave empty to avoid change)"
      f.input :password_confirmation, required: false
    end
    f.actions
  end

  controller do
    def update
      # TRICKY: We only want to change a password when a change is requested - if the password is blank we remove the
      # password update params before updating the record
      update_params = permitted_params.require(:user)
      update_params = update_params.except(:password, :password_confirmation) if update_params[:password].blank?

      if resource.update(update_params)
        redirect_to admin_user_path(resource)
      else
        render action: :edit
      end
    end
  end
end
