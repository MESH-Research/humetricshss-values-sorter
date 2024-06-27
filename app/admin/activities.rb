# frozen_string_literal: true

ActiveAdmin.register Activity do
  menu priority: 2

  permit_params :name, :icon_class

  # TRICKY: This scopes data to Library.main for the index, but not for other actions, which allows us to examine user
  # libraries using the same admin pages
  scope_to do
    next if params.include?(:id)

    Library.main
  end

  index do
    selectable_column
    column :icon_class do |activity|
      content_tag(:i, nil, class: activity.icon_class) + " " + content_tag(:span, activity.icon_class)
    end
    column :name
    actions
  end

  show do
    attributes_table do
      row :icon_class do |activity|
        content_tag(:i, nil, class: activity.icon_class) + " " + content_tag(:span, activity.icon_class)
      end
      row :name
    end
  end

  config.filters = false

  form do |f|
    f.inputs do
      f.input :icon_class
      f.input :name
    end
    f.actions
  end

  controller do
    def destroy
      super
      flash.alert = resource.errors.first.full_message if resource.errors.any?
    end
  end
end
