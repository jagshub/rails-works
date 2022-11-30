# frozen_string_literal: true

class Frontend::GraphqlController < Frontend::BaseController
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation
  include SetLastActiveAt

  before_action :dev_regenerate_graphql_files
  before_action :validate_query
  after_action :update_current_user_browser_log
  after_action :sweep_flash_messages

  def index
    result = Graph::Schema.execute(query, variables: variables, context: context)

    render json: result
  rescue StandardError => e
    render Graph::Utils::ControllerHelpers.handle_error(e, query: query, variables: variables, request: request)
  end

  add_transaction_tracer :index

  # Note(AR): This method is being called from outside this controller as
  # `controller.operation` for logging purposes.
  def operation
    Graph::Utils::ControllerHelpers.operation_from_query(query)
  end

  private

  def query
    Utf8Sanitize.call(params[:query].to_s)
  end

  def context
    {
      current_user: current_user,
      visitor_id: cookies[:visitor_id],
      cookies: cookies,
      session: session,
      request: request,
      request_info: RequestInfo.new(request),
      impersonated: impersonated?,
    }
  end

  def variables
    Graph::Utils::ControllerHelpers.variables(params[:variables])
  end

  def validate_query
    if query.blank?
      render json: { data: {} }
    elsif query.length > 15_000
      handle_error StandardError.new("GraphQL query size exceeded: #{ query.length }. Max length: 15000")
    end
  end

  def update_current_user_browser_log
    country = request.headers.env['HTTP_CF_IPCOUNTRY']
    Users::BrowserLog.append_to_user(current_user, request.user_agent, country)
  rescue StandardError => e
    ErrorReporting.report_warning(e)
  end

  def sweep_flash_messages
    flash.sweep
  end

  def dev_regenerate_graphql_files
    return unless Rails.env.development?

    file_changes_path = Rails.root.join('tmp', 'graphql-file-changes.json')
    return unless file_changes_path.exist?

    changed_extensions = JSON.parse(file_changes_path.read)
    return if changed_extensions.blank?

    if changed_extensions.include?('.rb')
      Graph::Utils::Export.delete_existing_files
      Graph::Utils::Export.export_schema
      Graph::Utils::Export.export_fragment_types
      Graph::Utils::Export.run_apollo_codegen
    elsif changed_extensions.include?('.graphql')
      Graph::Utils::Export.delete_existing_files
      Graph::Utils::Export.run_apollo_codegen
    else
      raise "Unexpected extension in: #{ changed_extensions.inspect }"
    end

    File.write(file_changes_path.to_s, '[]')
  end
end
