# frozen_string_literal: true

module Graph::Resolvers::Moderation
  class PossibleDuplicatePosts < Graph::Resolvers::Base
    type Graph::Types::PostType.connection_type, null: true

    def resolve
      PostDuplicatesLoader.for.load(object)
    end

    class PostDuplicatesLoader < GraphQL::Batch::Loader
      def perform(posts)
        urls =
          Post
          .joins(:primary_link)
          .where(posts: { id: posts.map(&:id) })
          .select('legacy_product_links.clean_url')
          .pluck(:clean_url)

        similar_posts_url_map =
          Post
          .joins(:primary_link)
          .where(legacy_product_links: { clean_url: urls })
          .select('posts.*, legacy_product_links.clean_url as clean_url')
          .group_by(&:clean_url)

        posts.each do |post|
          url = post.primary_link.clean_url
          possible = similar_posts_url_map[url].reject { |p| p.id == post.id }

          fulfill post, possible || []
        end
      end
    end
  end
end
