# frozen_string_literal: true

ActiveAdmin.register Advice, as: "MainLibraryAdvice" do
  menu label: "Advice", priority: 3

  permit_params :activity_id, :value_id, :text, :details, :published_state

  # TRICKY: Without `association_method` this will try to use Library.main.main_library_advice
  scope_to(association_method: :advice) { Library.main }

  scope :published, default: true
  scope :draft

  includes :activity, :value, :rich_text_details

  index do
    selectable_column
    column :attribution
    column :activity
    column :value
    column :text
    column(:details?) { |advice| advice.details.present? ? "Yes" : "No" }
    column(:state) { |advice| advice.published? ? "Published" : "Draft" }
    actions do |advice|
      item "Duplicate",  new_admin_main_library_advice_path(advice: { activity_id: advice.activity_id, value_id: advice.value_id, text: advice.text, details: advice.details&.body&.to_html })
    end
  end

  show do
    attributes_table do
      row :attribution
      row :activity
      row :value
      row :text
      row(:details) { |advice| advice.details.to_s }
      row(:state) { |advice| advice.published? ? "Published" : "Draft" }
    end
  end

  filter :activity, collection: -> { Library.main.activities }
  filter :value, collection: -> { Library.main.values }
  filter :text
  filter :details

  form do |f|
    f.inputs do
      f.input :attribution
      f.input :activity, collection: Library.main.activities
      f.input :value, collection: Library.main.values
      f.input :text
      f.input :details, as: :admin_rich_text_area
      f.input :published_state, collection: Advice.published_states.keys, include_blank: false
    end
    f.actions
  end
end
