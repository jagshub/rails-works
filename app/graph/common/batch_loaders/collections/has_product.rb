# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class Collections::HasProduct < GraphQL::Batch::Loader
    attr_reader :product_id

    def initialize(product_id:)
      @product_id = product_id
    end

    def perform(collections)
      collection_ids_with_product =
        Collection::ProductAssociation
          .where(collection: collections)
          .where(product_id: product_id)
          .group(:collection_id)
          .count # NOTE(DZ): Count is to aggregate query results since we are using group.
          .keys

      collections.each do |collection|
        fulfill collection, collection_ids_with_product.include?(collection.id)
      end
    end
  end
end
