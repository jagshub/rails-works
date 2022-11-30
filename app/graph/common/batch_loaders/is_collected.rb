# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class IsCollected < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(posts)
      return false unless @user

      collection_ids = Collection.for_curator(user: @user).pluck(:id)
      collection_post_ids = CollectionPostAssociation.where(post_id: posts.map(&:id), collection_id: collection_ids).pluck(Arel.sql('DISTINCT post_id'))

      posts.each do |post|
        fulfill post, collection_post_ids.include?(post.id)
      end
    end
  end
end
