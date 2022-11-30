# frozen_string_literal: true

class Graph::Resolvers::ProductRequests::UserResolver < Graph::Resolvers::Base
  type Graph::Types::UserType, null: true

  def resolve
    return if object.anonymous?

    Graph::Utils::AssociationResolver::AssociationLoader.for(:user).load(object)
  end
end
