# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV["APPLICATION_MAILER_FROM"]
  layout "mailer"
end
