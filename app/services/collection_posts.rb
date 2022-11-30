# frozen_string_literal: true

module CollectionPosts
  extend self

  def add(collection, post_id, _params = {})
    HandleRaceCondition.call do
      assoc = collection.collection_post_associations.find_or_create_by(post_id: post_id)

      schedule_workers(assoc.collection) if assoc.errors.empty?
      assoc
    end
  end

  def add_post_set(collections, post, current_user)
    post.collection_post_associations.joins(:collection).where('collections.user_id' => current_user.id).destroy_all

    collections.each do |collection|
      add(collection, post.id)
    end
    post.reload
  end

  def remove(assoc)
    if assoc.present?
      assoc.destroy!

      schedule_workers(assoc.collection)
    end

    assoc
  end

  def schedule_workers(collection)
    Collections::SimilarCollectionsWorker.perform_later(collection)
    Collections::AssignTopicsWorker.perform_later(collection)
  end
end
