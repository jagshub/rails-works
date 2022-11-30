# frozen_string_literal: true

module ErrorReporting
  extend self

  def set_user(**user_params)
    Sentry.set_user(**user_params)
  end

  def report_error(e, **options)
    # Note(AR): level: :error is the default
    Sentry.capture_exception(e, **options)
  end

  def report_warning(e, **options)
    Sentry.capture_exception(e, level: :warning, **options)
  end

  def report_error_message(message, **options)
    Sentry.capture_message(message, level: :error, **options)
  end

  def report_warning_message(message, **options)
    Sentry.capture_message(message, level: :warning, **options)
  end

  def report_graphql_error(e, query:, variables:, **options)
    query = pretty_print_query(query)
    variables = sanitize_variables(variables)

    options = options.deep_merge(extra: { query: query, variables: variables })
    options[:extra][:staging_id] = Config.staging_id if Rails.env.staging?

    Sentry.capture_exception(e, **options)
  end

  def pretty_print_query(query)
    document = GraphQL.parse(query)
    GraphQL::Language::Printer.new.print(document)
  end

  def sanitize_variables(variables)
    variables.permit! if variables.is_a?(ActionController::Parameters)
    parameter_filter = ActiveSupport::ParameterFilter.new(%i(email password))
    parameter_filter.filter(variables.to_h)
  end

  def set_graphql_path(path)
    Sentry.set_context 'graphql_info', path: path
  end

  def graphql_query_context_path
    Sentry.get_current_scope.contexts.dig('graphql_info', :path)
  end
end
