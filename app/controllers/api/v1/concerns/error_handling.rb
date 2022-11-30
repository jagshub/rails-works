# frozen_string_literal: true

module ErrorHandling
  extend ActiveSupport::Concern

  included do
    class WritePermissions < StandardError; end

    rescue_from WritePermissions, with: :handle_access_denied
    rescue_from API::V1::Errors::InvalidInput, with: :handle_invalid_input
    rescue_from KittyPolicy::AccessDenied, with: :handle_access_denied
    rescue_from RateLimiter::LimitReachedError, with: :handle_rate_limit_reached
    rescue_from Twitter::Error::ClientError, with: :handle_known_app_signin_error
    rescue_from Twitter::Error::ServerError, with: :handle_known_app_signin_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from ActionController::ParameterMissing, with: :handle_other_error
    rescue_from JSON::ParserError, with: :handle_other_error
  end

  # Note(andreasklinger): Historically we returned 401 on unauthorized requests. It seems doorkeeper_authorize! triggers a 403
  #   To not break the contract we monkeypatch this method from https://github.com/doorkeeper-gem/doorkeeper/blob/master/lib/doorkeeper/rails/helpers.rb
  #   The main difference is that options can contain a status (see the `||=`)
  def doorkeeper_render_error_with(error)
    options = doorkeeper_render_options(error) || {}
    status = doorkeeper_status_for_error(error, options.delete(:respond_not_found_when_forbidden))
    if options.blank?
      head status
    else
      options[:status] ||= status
      options[:layout] = false if options[:layout].nil?
      render options
    end
  end

  def doorkeeper_unauthorized_render_options(*)
    {
      json: access_unauthorized,
    }
  end

  # Note(andreasklinger): by default this should be http status: forbidden & json body error: 'access_denied'
  def doorkeeper_forbidden_render_options(*)
    {
      json: access_unauthorized,
      status: :unauthorized,
    }
  end

  def handle_access_unauthorized
    render json: access_unauthorized,
           status: :unauthorized
  end

  def handle_error_validation(model)
    # Note (Mike Coutermarsh): Do not expose slug error via API.
    model.errors.delete(:slug)
    render json: unprocessable_entity(model),
           status: :unprocessable_entity
  end

  def handle_record_not_found
    render json: not_found,
           status: :not_found
  end

  def handle_access_denied(error)
    render json: access_denied(error.class, error.message),
           status: :forbidden
  end

  def handle_rate_limit_reached(error)
    render json: rate_limit_reached_error(error.rate_limiter),
           status: :too_many_requests
  end

  def handle_other_error(error)
    render json: other_error(error.class, error.message),
           status: :error
  end

  def handle_known_app_signin_error(error)
    render json: known_app_signin_error(error.class, error.message),
           status: :bad_request
  end

  def handle_known_app_not_found(app)
    render json: known_app_not_found(app),
           status: :bad_request
  end

  def handle_invalid_input(error)
    render json: invalid_input(error.messages),
           status: :unprocessable_entity
  end

  def not_found
    {
      error: 'not_found',
      error_description: 'We could not find any object with this ID',
    }
  end

  def other_error(title, message)
    {
      error: 'internal_error',
      error_description: 'An error happend within our application. If this problem persists please contact us.',
      details: "#{ title }: #{ message }",
    }
  end

  def access_denied(title, message)
    {
      error: 'access_denied',
      error_description: 'Sorry. You are not allowed to do this. If you suspect this is an error please contact our support team.',
      details: "#{ title }: #{ message }",
    }
  end

  def rate_limit_reached_error(rate_limiter)
    {
      error: 'rate_limit_reached',
      error_description: 'Sorry. You have exceeded the API rate limit, please try again later.',
      details: {
        limit: rate_limiter.limit,
        remaining: rate_limiter.remaining,
        reset_in: rate_limiter.seconds_until_reset,
      },
    }
  end

  def unprocessable_entity(model)
    {
      error: 'unprocessable_entity',
      error_description: 'We could not save the resource, most likely the given parameters were incorrect',
      details: model.errors.to_hash,
    }
  end

  def invalid_input(error_messages)
    {
      error: 'unprocessable_entity',
      error_description: 'The given input was incorrect',
      details: error_messages,
    }
  end

  def duplicate_content(model)
    {
      error: 'duplicate_content',
      error_description: 'We could not save the resource, because we already have a similar submission.',
      details: model.errors,
      duplicate: { type: 'Post', id: Posts::Duplicates.find_all(post: model).first&.id },
    }
  end

  def access_unauthorized
    {
      error: 'unauthorized_oauth',
      error_description: 'Please supply a valid access token. Refer to our api documentation about how to authorize an api request. Please also make sure you require the correct scopes. Eg "private public" for to access private endpoints.',
    }
  end

  def known_app_signin_error(title, message)
    {
      error: 'app_signin_error',
      error_description: 'We received an error from Twitter when trying to make a request on behalf of your custom application.',
      details: "#{ title }: #{ message }",
    }
  end

  def known_app_not_found(app)
    {
      error: 'app_not_found',
      error_description: "Could not find an custom application with the name '#{ app }'",
    }
  end
end
