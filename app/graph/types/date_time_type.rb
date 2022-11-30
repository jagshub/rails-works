# frozen_string_literal: true

module Graph::Types
  class DateTimeType < BaseScalar
    def self.coerce_input(value, _ctx)
      value ? Time.zone.parse(value) : nil
    end

    def self.coerce_result(value, _ctx)
      value ? value.iso8601 : nil
    end
  end
end
