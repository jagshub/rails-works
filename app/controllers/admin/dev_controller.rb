# frozen_string_literal: true

class Admin::DevController < ApplicationController
  def index
    authenticate_admin_user!
  end

  def legacy_graphql_mobile
    raise "Shouldn't be accessed" unless Config.graphiql_enabled?

    context = {
      current_application: OAuth::Application.find(Config.official_mobile_app_id),
      current_user: current_user,
      request: request,
    }

    variables = Graph::Utils::ControllerHelpers.variables(params[:variables])

    render json: API::V2Internal::Schema.execute(params[:query], variables: variables, context: context)
  rescue StandardError => e
    render Graph::Utils::ControllerHelpers.handle_error(e)
  end

  def graphql_mobile
    raise "Shouldn't be accessed" unless Config.graphiql_enabled?

    context = {
      current_application: OAuth::Application.find(Config.official_mobile_app_id),
      current_user: current_user,
      request: request,
      session: session,
    }

    variables = Graph::Utils::ControllerHelpers.variables(params[:variables])

    render json: Mobile::Graph::Schema.execute(params[:query], variables: variables, context: context)
  rescue StandardError => e
    render Graph::Utils::ControllerHelpers.handle_error(e)
  end
end
