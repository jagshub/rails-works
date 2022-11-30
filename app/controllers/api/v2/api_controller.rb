# frozen_string_literal: true

class API::V2::APIController < ActionController::API
  before_action :ensure_proper_format
  before_action :ensure_query
  before_action :ensure_valid_token
  before_action :set_current_application
  before_action :set_current_user
  before_action :ensure_access_for_application
  after_action :record_application_request

  include RateLimiting
  rescue_from RateLimiter::LimitReachedError, with: :handle_rate_limit_reached

  attr_reader :current_application, :current_user

  def index
    variables = Graph::Utils::ControllerHelpers.variables(params[:variables])

    render json: API::V2::Schema.execute(query, variables: variables, context: context)
  rescue StandardError => e
    render Graph::Utils::ControllerHelpers.handle_error(e, query: query, variables: variables, request: request)
  end

  private

  def rate_limit_points_in_request
    # NOTE(Dhruv): If context does not have `:complexity_score` set, most likely
    # it is due to an invalid graphql query. Default to 100 so that invalid queries
    # are rate limited as well.
    context[:complexity_score] || 100
  end

  def rate_limit_points_quota_per_hour(app)
    app.max_points_per_hour
  end

  def rate_limit_identifier_for_limiter
    OAuth::Application::V2_GRAPHQL_IDENTIFIER
  end

  def ensure_proper_format
    request.format = :json
  end

  def ensure_query
    render_error :bad_request, error: 'query_missing', error_description: 'The query object is missing in the request body.' if query.blank?
  end

  def ensure_valid_token
    render_error :unauthorized, error: 'invalid_oauth_token', error_description: 'Please supply a valid access token. Refer to our api documentation about how to authorize an api request. Please also make sure you require the correct scopes. Eg "private public" for to access private endpoints.' unless doorkeeper_token&.acceptable? :public
  end

  def set_current_application
    render_error :bad_request, error: 'invalid_oauth_token', error_description: 'OAuth application not found.' if doorkeeper_token.application.blank?

    @current_application = doorkeeper_token.application
  end

  def set_current_user
    return if doorkeeper_token.resource_owner_id.blank?

    @current_user = User.find(doorkeeper_token.resource_owner_id)
  rescue ActiveRecord::RecordNotFound
    render_error :bad_request, error: 'invalid_oauth_token', error_description: 'User not found.'
  end

  def ensure_access_for_application
    allowed_app_ids = Rails.configuration.settings.api_v2_beta_app_ids
    render_error :unauthorized, error: 'access_denied', error_description: 'The API is open to only beta apps currently. Please get in touch at hello@producthunt.com to get beta access.' unless allowed_app_ids.blank? || allowed_app_ids.include?(current_application&.uid)
  end

  def record_application_request
    ::OAuthApps::RecordLastRequest.perform_later(Time.current.iso8601, current_application.id, current_user&.id) if Rails.configuration.settings.api_v2_record_requests && current_application.present?
  end

  def handle_rate_limit_reached(error)
    rate_limit_details = {
      limit: error.rate_limiter.limit,
      remaining: error.rate_limiter.remaining,
      reset_in: error.rate_limiter.seconds_until_reset,
    }

    render_error :too_many_requests, error: 'rate_limit_reached', error_description: 'Sorry. You have exceeded the API rate limit, please try again later.', details: rate_limit_details
  end

  def query
    params[:query]
  end

  def context
    @context ||= {
      current_application: current_application,
      current_user: current_user,
      request: request,
      allowed_scopes: doorkeeper_token.scopes.to_a,
    }
  end

  def render_error(status, error_json)
    render json: { data: nil, errors: [error_json] }, status: status
  end
end
