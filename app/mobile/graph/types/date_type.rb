# frozen_string_literal: true

module Mobile::Graph::Types
  class DateType < BaseScalar
    def self.coerce_input(value, _ctx)
      value ? Date.iso8601(value) : nil
    end

    def self.coerce_result(value, _ctx)
      value ? value.iso8601 : nil
    end
  end
end
