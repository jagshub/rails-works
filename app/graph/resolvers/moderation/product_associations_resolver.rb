# frozen_string_literal: true

module Graph::Resolvers::Moderation
  class ProductAssociationsResolver < Graph::Resolvers::Base
    type [Graph::Types::ProductAssociationType], null: false

    class RelationshipFilter < Graph::Types::BaseEnum
      graphql_name 'ProductAssociationRelationshipFilterEnum'

      value 'all'
      value 'alternative'
      value 'related'
      value 'addon'
    end

    argument :product_id, ID, required: true
    argument :relationship_filter, RelationshipFilter, required: false

    def resolve(product_id:, relationship_filter: nil)
      relationship_filter ||= 'all'
      product = Product.find_by(id: product_id)
      return [] if product.nil?

      case relationship_filter
      when 'all' then product.product_associations.by_date
      when 'alternative' then product.alternative_associations.by_date
      when 'related' then product.related_product_associations.by_date
      when 'addon' then product.addon_associations.by_date
      else
        raise "Unknown relationship filter: #{ relationship_filter }"
      end
    end
  end
end
