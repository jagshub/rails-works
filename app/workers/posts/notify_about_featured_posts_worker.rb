# frozen_string_literal: true

class Posts::NotifyAboutFeaturedPostsWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors

  def perform
    Post.not_promoted.between_dates(1.day.ago, Time.current).find_each do |post|
      Post.transaction do
        post.update! promoted_at: Time.current

        Stream::Events::PostFeatured.trigger(user: post.user, subject: post, source: :application)
        Posts::NotifyCompanyOnTwitterWorker.perform_later(post)

        if post.featured_at.present? && post.new_product.present?
          post.new_product.refresh_posts_count
          Products::RefreshActivityEvents.new(post.new_product).call
        end

        post.product_makers.each do |product_maker|
          Notifications.notify_about(kind: 'friend_product_maker', object: product_maker)
        end
      end
    end
  end
end
