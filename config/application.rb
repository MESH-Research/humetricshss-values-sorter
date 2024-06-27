# frozen_string_literal: true

require_relative "boot"


require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


# TRICKY: Only set for review apps when unset by other means
ENV["APP_DOMAIN"] ||= "#{ENV["HEROKU_APP_NAME"]}.herokuapp.com" if ENV["HEROKU_APP_NAME"]
ENV["ASSET_HOST"] ||= "https://#{ENV["APP_DOMAIN"]}"

module ValuesSorter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # TRICKY: We need to do this in order for e.g. image assets to be delivered by Rails' mailers
    config.action_mailer.asset_host = ENV["ASSET_HOST"]

    # TRICKY: This avoids the usual error wrapping in forms. We use simple_form, and thus delegate such
    # responsibilities to that gem
    config.action_view.field_error_proc = ->(html_tag, _instance) { html_tag.html_safe }
  end
end
