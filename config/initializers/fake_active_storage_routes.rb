# frozen_string_literal: true

# TRICKY: We use Action Text to allow rich text content editing, but don't want to allow attachments via Active
# Storage. Action Text expects Active Storage routes to exist, however, so we fake them here to avoid raising
# NoMethodError when rendering the Action Text WYSIWIG editor.
#
# We could also do this by actually adding "fake" routes to config/routes.rb, like this:
#
#   get "/rails/active_storage/direct_uploads", to: "some#action", as: "rails_direct_uploads"
#
# In production, however, this causes Rails to fail to initialize ActiveStorage using the config. It then proceeds to
# attempt to draw the default routes, and raises an ArgumentError when routes with the given aliases already exist
class << Rails.application.routes.url_helpers
  def rails_service_blob_url(*_args)
    ""
  end

  def rails_direct_uploads_url(*_args)
    ""
  end
end
