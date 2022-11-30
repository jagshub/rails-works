# frozen_string_literal: true

class API::V2::GraphqlController < API::V2::BaseController
  include SetLastActiveAt

  before_action :authorize_with_docker
  before_action :ensure_producthunt_apps
  before_action :ensure_query

  def index
    render json: API::V2Internal::Schema.execute(query, variables: variables, context: context)
  rescue StandardError => e
    render Graph::Utils::ControllerHelpers.handle_error(e, query: query, variables: variables, request: request)
  end

  private

  def query
    params[:query]
  end

  def context
    {
      current_application: current_application,
      current_user: current_user,
      request: request,
    }
  end

  def variables
    Graph::Utils::ControllerHelpers.variables(params[:variables])
  end

  def ensure_producthunt_apps
    render json: { data: {}, errors: [{ message: 'application not allowed to access api v2' }, locations: [], path: []] } if Config.official_mobile_app_id != current_application.id
  end

  def ensure_query
    render json: { data: {} } if query.blank?
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
