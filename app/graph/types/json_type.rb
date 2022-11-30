# frozen_string_literal: true

module Graph::Types
  class JsonType < BaseScalar
    graphql_name 'JSON'

    def self.coerce_input(value, _ctx)
      value
    end

    def self.coerce_result(value, _ctx)
      value.as_json
    end
  end
end
