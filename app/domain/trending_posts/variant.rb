# frozen_string_literal: true

module TrendingPosts
  extend self

  class Variant
    def initialize(preferred_variant, current_user, exclude_product_ids, limit)
      @preferred_variant = preferred_variant
      @current_user = current_user
      @exclude_product_ids = exclude_product_ids
      @limit = limit
    end

    def variant
      config.name
    end

    def posts
      if @posts.blank?
        @posts = scope.where(featured_at: config.featured_at_range).limit(@limit)
        Rails.cache.write(config.cache_key, @posts.map(&:id), expires_in: config.cache_expiry)
      end

      if @exclude_product_ids.present?
        return Post
                 .by_ordered_ids(@posts.pluck(:id))
                 .joins(:new_product)
                 .where.not(new_product: { id: @exclude_product_ids })
      end
      @posts
    end

    private

    def config
      @config ||= TrendingPosts::VARIANTS.fetch(@preferred_variant).pick_or_fallback
    end

    def scope
      Post.featured.select("*, (#{ ::Posts::Ranking.algorithm_in_sql }) as rank").order('rank DESC')
    end
  end
end
