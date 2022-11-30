# frozen_string_literal: true

class API::V1::BasicCommentSerializer < API::V1::BaseSerializer
  delegated_attributes :id, :body, :created_at, :parent_comment_id, :user_id, :subject_id, to: :resource
  attributes :child_comments_count, :url, :post_id, :subject_type, :sticky, :votes

  def url
    comment_url(resource)
  end

  def subject_type
    serialize_class_name resource.subject_type
  end

  def sticky
    resource.sticky?
  end

  def post_id
    return unless resource.subject_type == 'Post'

    resource.subject_id
  end

  def child_comments_count
    # Note(andreasklinger): Using `size` instead of `count` to avoid generating another
    #   `select count(*)...` query
    resource.children.size
  end

  def votes
    resource.votes_count
  end
end
