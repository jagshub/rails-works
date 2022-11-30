# frozen_string_literal: true

module API::V2::Types
  class DateTimeType < BaseScalar
    description 'An ISO-8601 encoded UTC date string.'

    def self.coerce_input(value, _ctx)
      value ? Time.zone.parse(value) : nil
    # NOTE(Dhruv): Ignore invalid DateTime inputs
    rescue ArgumentError, TypeError
      nil
    end

    def self.coerce_result(value, _ctx)
      value ? value.utc.iso8601 : nil
    end
  end
end
