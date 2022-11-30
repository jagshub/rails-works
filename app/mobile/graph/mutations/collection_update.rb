# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CollectionUpdate < BaseMutation
    argument_record :collection, Collection, required: true, authorize: :update
    argument :name, String, required: false
    argument :title, String, required: false
    argument :description, String, required: false
    argument :image_uuid, String, required: false

    returns Mobile::Graph::Types::CollectionType

    def perform(collection:, **params)
      collection.update(params)
      collection
    end
  end
end
