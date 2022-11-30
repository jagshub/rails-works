# frozen_string_literal: true

class Graph::Resolvers::Products::FindByPostNameResolver < Graph::Resolvers::Base
  argument :name, String, required: true

  type [Graph::Types::ProductType], null: true

  def resolve(name:)
    Products::Find.with_name_included_in(name)
  end
end
