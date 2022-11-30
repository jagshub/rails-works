# frozen_string_literal: true

class Graph::Resolvers::Products::FindByUrlResolver < Graph::Resolvers::Base
  argument :url, String, required: true

  type Graph::Types::ProductType, null: true

  def resolve(url:)
    Products::Find.by_url(url)
  end
end
