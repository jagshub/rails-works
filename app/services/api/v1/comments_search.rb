# frozen_string_literal: true

class API::V1::CommentsSearch
  include SearchObject.module
  include API::V1::Sorting

  scope { Comment.visible.with_preloads_for_api.preload(:subject) }

  def initialize(options = {})
    super(options)
  end
  # rubocop: enable

  sort_by :id, :created_at, :updated_at
  option(:user_id) { |scope, value| scope.where(user_id: value).preload(user: User.preload_attributes) }
  option(:post_id) { |scope, value| scope.where(subject_id: value, subject_type: 'Post').preload(subject: Post.preload_attributes_for_api) }
  option(:top_level_only) { |scope, value| scope.top_level if value == true }
end
