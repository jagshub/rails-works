# frozen_string_literal: true

# NOTE(emilov): tracer for each graphql call, see it used in app/graph/schema.rb
# When used, each graphql call's duration is measured and logged as JSON to be aggregated in Graylog later.
class Graph::Utils::Tracer
  def self.trace(key, data)
    started_at = Time.zone.now
    yield.tap do
      t = Time.zone.now - started_at
      next if t <= 0.1 # NOTE (emilov): skip small duration events

      info = prep_info(key, data, t)
      Rails.logger.info({ graphql_trace: info }.to_json) if info
    end
  end

  def self.prep_info(key, data, duration)
    info = {
      key: key,
      duration: format('%.5f', duration),
    }

    if key == 'execute_field'
      info[:name] = data[:field].name
      return if info[:name] == '__typename'

      info[:type] = 'field'
      info[:query_name] = data[:query].operation_name
    elsif key == 'execute_query'
      info[:type] = 'query'
      info[:name] = data[:query].operation_name
    end

    info
  rescue StandardError => e
    ErrorReporting.report_error e
  end
end
