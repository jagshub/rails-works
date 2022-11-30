# frozen_string_literal: true

module Graph::Types
  class HTMLType < BaseScalar
    description 'A valid HTML string'

    def self.coerce_input(react_value, _ctx)
      Sanitizers::ReactToDb.call(react_value, mode: :none)
    end

    def self.coerce_result(db_value, _ctx)
      db_value
    end
  end
end
