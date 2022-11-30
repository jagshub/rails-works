# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class BadgeLinkedPost < GraphQL::Batch::Loader
    def perform(badges)
      badges_with_post = badges.filter { |badge| badge.data['for_post_id']&.present? }
      badges_without_post = badges.filter { |badge| !badge.data['for_post_id']&.present? }

      post_ids = badges.map { |badge| badge.data['for_post_id'].to_i }
      posts = ::Post.where(id: post_ids)

      badges_with_post.each do |badge|
        fulfill(badge, posts.find { |p| p.id == badge.data['for_post_id'].to_i })
      end

      badges_without_post.each do |badge|
        fulfill(badge, nil)
      end
    end
  end
end
