# frozen_string_literal: true

module Graph::Resolvers
  class Base < GraphQL::Schema::Resolver
    private

    def current_user
      @current_user ||= context[:current_user]
    end
  end
end
