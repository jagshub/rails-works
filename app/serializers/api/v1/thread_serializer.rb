# frozen_string_literal: true

class API::V1::ThreadSerializer < API::V1::CommentSerializer
  attributes :child_comments, :maker, :hunter, :live_guest

  def maker
    return false unless resource.subject.is_a? Post

    ProductMakers.maker_of?(user: resource.user, post_id: resource.subject.id)
  end

  def hunter
    return false unless resource.subject.is_a? Post

    resource.subject.user_id == resource.user_id
  end

  def live_guest
    false
  end

  def child_comments
    API::V1::ThreadSerializer.collection(resource.children.order(id: :asc), scope, root: false)
  end
end
