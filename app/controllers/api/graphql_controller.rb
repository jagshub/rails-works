# frozen_string_literal: true

class API::V3::GraphqlController < ActionController::API
  include ErrorHandling

  before_action :authorize_with_docker
  before_action :ensure_producthunt_apps
  before_action :ensure_query
  before_action :set_last_active_at
  before_action :set_device_last_active_at

  after_action :save_session

  def index
    render json: Mobile::Graph::Schema.execute(query, variables: variables, context: context)
  rescue StandardError => e
    render Graph::Utils::ControllerHelpers.handle_error(e, query: query, variables: variables, request: request)
  end

  private

  def current_user
    return @current_user if defined? @current_user
    return unless doorkeeper_token.present? && doorkeeper_token.resource_owner_id.present?

    @current_user ||= User.find(doorkeeper_token.resource_owner_id)
  end

  def current_application
    @current_application ||= doorkeeper_token.application
  end

  def query
    params[:query]
  end

  def context
    {
      current_application: current_application,
      current_user: current_user,
      request: request,
      visitor_id: request.headers['X-Visitor'],
      session: mobile_session,
    }
  end

  def mobile_session
    @mobile_session ||= begin
      if request.headers['X-Visitor'].nil? && current_user.nil?
        {}
      else
        Mobile::Session.new(session_key: request.headers['X-Visitor'].presence || "user:#{ current_user.id }")
      end
    end
  end

  def save_session
    return if mobile_session.is_a?(Hash)

    mobile_session.save
  end

  def variables
    Graph::Utils::ControllerHelpers.variables(params[:variables])
  end

  def ensure_producthunt_apps
    render json: { data: {}, errors: [{ message: 'application not allowed to access api v3' }, locations: [], path: []] } if Config.official_mobile_app_id != current_application.id
  end

  def ensure_query
    render json: { data: {} } if query.blank?
  end

  def set_last_active_at
    return if current_user.nil? || current_user.last_active_at&.today?

    current_user.last_active_ip = request.ip
    current_user.last_active_at = Time.zone.now.to_date

    current_user.save!
  end

  def set_device_last_active_at
    mobile_device = Mobile::Device.device_for(user: current_user, request: request)
    return if mobile_device.nil? || mobile_device.last_active_at&.today?

    mobile_device.update! last_active_at: Time.current
  end

  def authorize_with_docker
    # NOTE(rstankov): Our apps need to be able to export schema details
    # For security reasons this is only allowed in development
    if Rails.env.development? && request.authorization == 'Bearer EXPORT-SCHEMA'
      @current_application = OAuth::Application.find(Config.official_mobile_app_id)
      @current_user = nil
    else
      doorkeeper_authorize! :public
    end
  end
end
