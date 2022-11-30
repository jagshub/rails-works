# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class Collections::IsFollowed < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(collections)
      followed_ids = @user.active_collection_subscriptions.where(collection_id: collections.map(&:id)).pluck(:collection_id)

      collections.each do |collection|
        fulfill collection, followed_ids.include?(collection.id)
      end
    end
  end
end
