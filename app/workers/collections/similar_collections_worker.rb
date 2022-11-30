# frozen_string_literal: true

class Collections::SimilarCollectionsWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(collection)
    collection.similar_collection_associations.delete_all

    random_featured_collection_ids(id: collection.id).each do |similar_collection_id|
      create_similar collection: collection, similar_collection_id: similar_collection_id
    end
  end

  private

  def create_similar(collection:, similar_collection_id:)
    HandleRaceCondition.call do
      SimilarCollectionAssociation.find_or_create_by!(
        collection_id: collection.id,
        similar_collection_id: similar_collection_id,
      )
    end
  rescue ActiveRecord::RecordInvalid => e
    raise e unless ignore_error? e
  end

  IGNORABLE_ERRORS = ['already added as similar', "collection can't be blank"].freeze

  def ignore_error?(e)
    IGNORABLE_ERRORS.any? { |message| e.message.include?(message) }
  end

  def random_featured_collection_ids(id:)
    Collection.featured.where.not(id: id).by_random.limit(4).pluck(:id)
  end
end
