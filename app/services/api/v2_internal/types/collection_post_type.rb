# frozen_string_literal: true

module API::V2Internal::Types
  class CollectionPostType < BaseObject
    graphql_name 'CollectionPost'

    field :id, ID, null: true

    association :post, API::V2Internal::Types::PostType, null: false
    association :collection, API::V2Internal::Types::CollectionType, null: false
  end
end
