# frozen_string_literal: true

class Graph::Resolvers::Posts::RedirectToProductResolver < Graph::Resolvers::Base
  type Graph::Types::ProductType, null: true

  def resolve
    return unless object.archived?

    Graph::Utils::AssociationResolver::AssociationLoader.for(:new_product).load(object)
  end
end
