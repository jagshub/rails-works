# frozen_string_literal: true

module Mobile::Graph::Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    private

    def current_user
      @current_user ||= context[:current_user]
    end
  end
end
