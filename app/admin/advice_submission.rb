# frozen_string_literal: true

ActiveAdmin.register AdviceSubmission do
  menu label: "Submissions", priority: 3
  actions :all, except: %i[new create destroy]
  config.batch_actions = false

  permit_params :author_name, :published_activity_id, :published_value_id, :text, :details
  includes :published_activity, :published_value, :rich_text_details

  scope :pending, default: true
  scope :all
  scope :accepted
  scope :declined

  filter :published_activity, collection: -> { Library.main.activities }
  filter :published_value, collection:  -> { Library.main.values }
  filter :text

  index do
    selectable_column
    column :submitter
    column :published_activity
    column :published_value
    column :text
    column(:details?) { |submission| submission.details.present? ? "Yes" : "No" }

    column :status do |submission|
      case submission.status.to_sym
      when :declined
        "Declined"
      when :pending
        "Pending review"
      when :accepted
        link_to("Published", admin_main_library_advice_path(submission.published_advice))
      end
    end

    column { |submission| link_to("Review", admin_advice_submission_path(submission)) }
  end

  show do
    attributes_table do
      row :submitter
      row :attribution

      if advice_submission.uses_custom_activity?
        row (:custom_value) do |advice_submission|
          [
            advice_submission.custom_activity,
            link_to("+ Add new Activity", new_admin_activity_path(activity: { name: advice_submission.custom_activity }))
          ].join(" ").html_safe
        end
      else
        row :published_activity
      end

      if advice_submission.uses_custom_value?
        row (:custom_value) do |advice_submission|
          [
            advice_submission.custom_value,
            link_to("+ Add new Value", new_admin_value_path(value: { name: advice_submission.custom_value }))
          ].join(" ").html_safe
        end
      else
        row :published_value
      end

      row :text
      row(:details) { |advice_submission| advice_submission.details.to_s }

      row :status do |advice_submission|
        if advice_submission.pending?
          "Submitted #{advice_submission.created_at.strftime("%m/%d/%Y")}"
        else
          "#{advice_submission.status.titleize} #{advice_submission.updated_at.strftime("%m/%d/%Y")}"
        end
      end
    end
  end

  action_item :view, only: :show do
    if advice_submission.pending? && advice_submission.ready_to_publish?
      link_to "Accept", accept_admin_advice_submission_path(advice_submission), method: :put
    end
  end

  action_item :view, only: :show do
    if advice_submission.pending?
      link_to "Decline", decline_admin_advice_submission_path(advice_submission), method: :put, "data-confirm": "Are you sure?"
    end
  end

  member_action :accept, method: :put do
    resource.accept!
    redirect_to admin_advice_submissions_path, notice: "Submission accepted"
  rescue AdviceSubmission::NonpendingSubmissionError, AdviceSubmission::UnpublishableSubmissionError => e
    redirect_to resource_path, alert: e.to_s
  end

  member_action :decline, method: :put do
    resource.decline!
    redirect_to admin_advice_submissions_path, notice: "Submission declined"
  rescue AdviceSubmission::NonpendingSubmissionError => e
    redirect_to resource_path, alert: e.to_s
  end

  form do |f|
    f.inputs do
      # TRICKY: We want to display attribution, but save to the author_name field
      f.input :author_name, label: "Attribution", input_html: { value: advice_submission.attribution }
      f.input :custom_activity, input_html: { disabled: true }
      f.input :published_activity, collection: Library.main.activities
      f.input :custom_value, input_html: { disabled: true }
      f.input :published_value, collection: Library.main.values
      f.input :text
      f.input :details, as: :admin_rich_text_area
    end

    f.actions do
      f.action :submit, label: "Save changes"
    end
  end
end
