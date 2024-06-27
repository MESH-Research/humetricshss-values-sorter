# frozen_string_literal: true

# TRICKY: This registration serves user library advice. Advice in the main library is managed via the registration in
# app/admin/main_library_advice.rb
ActiveAdmin.register Advice do
  menu false

  # TRICKY: These actions caused issues related to library_id, but admins should not create user advice anyway. Disable
  # for simplicity
  actions :all, except: [:new, :create]

  permit_params :activity_id, :value_id, :text, :details
  belongs_to :user

  includes :activity, :value, :rich_text_details

  index do
    selectable_column
    column :activity
    column :value
    column :text
    column(:details?) { |advice| advice.details.present? ? "Yes" : "No" }
    actions
  end

  show do
    attributes_table do
      row :activity
      row :value
      row :text
      row(:details) { |advice| advice.details.to_s }
    end
  end

  filter :activity, collection: -> { @user.activities }
  filter :value, collection:  -> { @user.values }
  filter :text
  filter :details

  form do |f|
    f.inputs do
      f.input :activity, collection: user.activities
      f.input :value, collection: user.values
      f.input :text
      f.input :details, as: :admin_rich_text_area
    end
    f.actions
  end
end
