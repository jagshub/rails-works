# frozen_string_literal: true

class API::V2Internal::Resolvers::IsPostCollectedResolver < Graph::Resolvers::Base
  type Boolean, null: true

  def resolve
    return false if current_user.blank?

    IsPostCollectedLoader.for(current_user).load(object)
  end

  class IsPostCollectedLoader < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(posts)
      post_ids = CollectionPostAssociation.where(collection_id: Collection.for_curator(user: @user).select(:id), post_id: posts.map(&:id)).pluck(:post_id)

      posts.each do |post|
        fulfill post, post_ids.include?(post.id)
      end
    end
  end
end
