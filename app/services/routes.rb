# frozen_string_literal: true

module Routes
  class << self
    include Rails.application.routes.url_helpers
    include Routes::CustomPaths
    include Routes::FrontendPaths
  end

  include Rails.application.routes.url_helpers
  include Routes::CustomPaths
  include Routes::FrontendPaths

  def default_url_options
    Rails.application.routes.default_url_options
  end
end
