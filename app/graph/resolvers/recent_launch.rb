# frozen_string_literal: true

module Graph::Resolvers
  class RecentLaunch < Graph::Resolvers::Base
    type Graph::Types::PostType, null: true

    def resolve
      return if current_user.blank?
      return if current_user.posts_count.zero? && current_user.product_makers_count.zero?

      current_user
        .hunted_or_made
        .where(Post.date_arel.gt(1.week.ago))
        .by_created_at
        .first
    end
    add_method_tracer :recent_launch, 'ViewerType/recent_launch'
  end
end
