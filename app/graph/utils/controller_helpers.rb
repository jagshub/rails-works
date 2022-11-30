# frozen_string_literal: true

module Graph::Utils::ControllerHelpers
  extend self

  def variables(input)
    if input.blank?
      {}
    elsif input.is_a?(String)
      parse_json input
    else
      input
    end
  end

  def handle_error(error, query: nil, variables: nil, request: nil)
    if Rails.env.development?
      field_path = ErrorReporting.graphql_query_context_path

      Rails.logger.error
      Rails.logger.error error.message
      Rails.logger.error "Variables: #{ variables.inspect }"
      Rails.logger.error "Field Path: #{ field_path }" if field_path.present?
      Rails.logger.error Rails.backtrace_cleaner.clean(error.backtrace)&.join("\n")

      { json: { error: { message: error.message, path: field_path, backtrace: error.backtrace }, data: {} }, status: 500 }
    elsif Rails.env.test?
      field_path = ErrorReporting.graphql_query_context_path

      # rubocop:disable Rails/Output
      puts error.message
      puts "Operation: #{ operation_from_query(query) }"
      puts "Variables: #{ variables.inspect }"
      puts "Field Path: #{ field_path }" if field_path.present?
      puts Rails.backtrace_cleaner.clean(error.backtrace)&.join("\n")
      # rubocop:enable Rails/Output

      { json: { error: { message: error.message, path: field_path, backtrace: error.backtrace }, data: {} }, status: 500 }
    else
      ErrorReporting.report_graphql_error(error, query: query, variables: variables, extra: { referer: request&.referer })

      { json: { error: { message: 'SERVER_ERROR' }, data: {} }, status: 500 }
    end
  end

  # NOTE(emilov): given a graphql query return the operation
  # e.g. "query HomePage($blalba..." => "query HomePage"
  RX = /((query|mutation)\s\w+)/.freeze

  def operation_from_query(query)
    RX.match(query)&.captures&.first
  end

  private

  def parse_json(data)
    JSON.parse(data)
  rescue JSON::ParserError
    {}
  end
end
