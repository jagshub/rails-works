# frozen_string_literal: true

class API::V1::CollectionSerializer < API::V1::BasicCollectionSerializer
  attributes :posts

  def posts
    API::V1::BasicPostSerializer.collection(resource.posts, scope, root: false)
  end
end
