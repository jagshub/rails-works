# frozen_string_literal: true

class API::V1::Collections::CollectedPostSerializer < API::V1::BaseSerializer
  delegated_attributes :id, :post_id, :collection_id, to: :resource
  attributes :collection

  def collection
    API::V1::CollectionSerializer.new(resource.collection, scope)
  end
end
