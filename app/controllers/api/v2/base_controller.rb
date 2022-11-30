# frozen_string_literal: true

class API::V2::BaseController < ActionController::API
  include RateLimiting
  include ErrorHandling

  private

  def rate_limit_points_in_request
    1
  end

  def rate_limit_points_quota_per_hour(app)
    app.max_requests_per_hour
  end

  def current_user
    return @current_user if defined? @current_user
    return unless doorkeeper_token.present? && doorkeeper_token.resource_owner_id.present?

    @current_user ||= User.find(doorkeeper_token.resource_owner_id)
  end

  def current_application
    @current_application ||= doorkeeper_token.application
  end
end
