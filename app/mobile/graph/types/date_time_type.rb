# frozen_string_literal: true

module Mobile::Graph::Types
  class DateTimeType < BaseScalar
    graphql_name 'DateTime'

    def self.coerce_input(value, _ctx)
      value ? Time.zone.parse(value) : nil
    end

    def self.coerce_result(value, _ctx)
      value ? value.iso8601 : nil
    end
  end
end
