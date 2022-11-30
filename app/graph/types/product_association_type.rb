# frozen_string_literal: true

module Graph::Types
  class ProductAssociationType < BaseObject
    implements Graph::Types::VotableInterfaceType

    class RelationshipEnumType < BaseEnum
      graphql_name 'ProductAssociationRelationshipEnum'

      ::Products::ProductAssociation.relationships.keys.each do |key|
        value key, key.humanize.capitalize
      end
    end

    field :id, ID, null: false
    field :relationship, RelationshipEnumType, null: false

    association :product, Graph::Types::ProductType, null: false
    association :associated_product, Graph::Types::ProductType, null: false
  end
end
