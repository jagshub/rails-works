# frozen_string_literal: true

class Mobile::Graph::Resolvers::Comments::Find < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::CommentType, null: true

  argument :id, ID, required: false
  argument :find_root, Boolean, required: false

  def resolve(id:, find_root: false)
    comment = Comment.visible.find_by(id: id)

    if comment && find_root
      comment.parent.presence || comment
    else
      comment
    end
  end
end
