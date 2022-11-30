# frozen_string_literal: true

module Graph::Types
  class Products::ConnectionType < BaseConnection
    graphql_name 'ProductsConnection'
    edge_type Graph::Types::ProductType.edge_type

    def total_count
      # Note(DT): Default count method:
      #   - fails when a custom `select` clause is used
      #   - returns Hash instead of Integer when a `group` clause is used
      #   - gives duplicates when `left join` is used
      # Products search query has all of these, so adjusting the query for count here.
      object.items.unscope(:select, :order, :group).distinct.count
    end
  end
end
