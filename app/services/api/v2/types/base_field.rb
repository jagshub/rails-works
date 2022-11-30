# frozen_string_literal: true

module API::V2::Types
  class BaseField < GraphQL::Schema::Field
    def initialize(*args, **kwargs, &block)
      super(*args, **kwargs, &block)
      extension(Graph::Utils::ReportingExtension)
    end
  end
end
