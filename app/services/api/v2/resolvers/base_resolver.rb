# frozen_string_literal: true

module API::V2::Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    delegate :current_user, :private_scope_allowed?, to: :context

    def can_resolve_private?
      current_user && private_scope_allowed?
    end
  end
end
