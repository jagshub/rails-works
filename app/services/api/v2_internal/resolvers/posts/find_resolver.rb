# frozen_string_literal: true

class API::V2Internal::Resolvers::Posts::FindResolver < Graph::Resolvers::Base
  argument :id, ID, required: false
  argument :slug, String, required: false
  argument :commentId, ID, required: false

  type API::V2Internal::Types::PostType, null: true

  def resolve(args = {})
    if args[:commentId]
      Comment.where(subject_type: 'Post').find(args[:commentId]).subject
    else
      Post.friendly.find args[:id] || args[:slug]
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
