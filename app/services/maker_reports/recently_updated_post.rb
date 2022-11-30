# frozen_string_literal: true

module MakerReports
  class RecentlyUpdatedPost
    attr_reader :activity_created_after, :activity_created_before, :post

    class << self
      def call(posts_created_before:, activity_created_after:, activity_created_before:)
        recently_commented_posts = Post
          .joins(:comments)
          .where('comments.created_at > coalesce((select activity_created_before from maker_reports where maker_reports.post_id = posts.id order by activity_created_after desc limit 1), ?)', activity_created_after)
          .where('comments.created_at < ?', activity_created_before)
          .where('comments.user_id NOT IN (select user_id from product_makers where product_makers.post_id = posts.id)')
          .where('posts.featured_at < ?', posts_created_before)

        recently_reviewed_posts = Post
          .joins(new_product: :reviews)
          .where('reviews.created_at > coalesce((select activity_created_before from maker_reports where maker_reports.post_id = posts.id order by activity_created_after desc limit 1), ?)', activity_created_after)
          .where('reviews.created_at < ?', activity_created_before)
          .where('reviews.user_id NOT IN (select user_id from product_makers where product_makers.post_id = posts.id)')
          .where('posts.featured_at < ?', posts_created_before)

        recently_associated_products = Product
          .joins(:posts)
          .joins(:product_associations)
          .where(product_associations: { source: ['moderation', 'admin'] })
          .where('product_associations.created_at < ?', activity_created_before)
          .where('coalesce((select activity_created_before from maker_reports where maker_reports.post_id = posts.id order by activity_created_after desc limit 1), product_associations.created_at) > ?', activity_created_after)
        recently_associated_posts = Post
          .joins(:new_product)
          .where(products: { id: recently_associated_products.select('product_associations.product_id') })
          .where('posts.featured_at < ?', posts_created_before)

        results = ActiveRecord::Base.connection.exec_query(<<-SQL)
          select distinct post_id
          from (
            #{ recently_commented_posts.select('posts.id AS post_id').to_sql }
            union all
            #{ recently_reviewed_posts.select('posts.id AS post_id').to_sql }
            union all
            #{ recently_associated_posts.select('posts.id AS post_id').to_sql }
          ) as recently_updated_posts
        SQL

        Post.where(id: results.rows.flatten)
      end
    end

    def initialize(maker_report)
      @post = maker_report.post
      @activity_created_after = maker_report.activity_created_after
      @activity_created_before = maker_report.activity_created_before
    end

    def comments
      post.comments
          .where.not(user: post.makers)
          .created_after(activity_created_after)
          .created_before(activity_created_before)
          .by_credible_votes_count
    end

    def reviews
      post.reviews
          .not_hidden
          .with_body
          .where.not(user: post.makers)
          .created_after(activity_created_after)
          .created_before(activity_created_before)
          .by_credible_votes_count
    end

    def product_associations
      return [] if post.new_product.blank?

      post.new_product
          .product_associations
          .created_after(activity_created_after)
          .created_before(activity_created_before)
    end

    def votes
      post.votes
          .visible
          .created_after(activity_created_after)
          .created_before(activity_created_before)
    end

    def activities?
      activity_count > 0
    end

    def activity_count
      product_associations.count + comments.count + reviews.count
    end
  end
end
