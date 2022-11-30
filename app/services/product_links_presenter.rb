# frozen_string_literal: true

module ProductLinksPresenter
  extend self

  def decorate_links(post:)
    default_store = DefaultStore.new
    sort_product_links(post).map do |product_link|
      store_name = product_link.store_name || default_store.value
      DecoratedProductLink.new(product_link: product_link, post: post, store_name: store_name)
    end
  end

  private

  def sort_product_links(post)
    # Primary links go first, then websites, then all stores
    post.links.sort_by { |r| r.primary_link? ? -1 : r[:store].to_i || 0 }
  end

  class DefaultStore
    def initialize
      @website = true
    end

    def value
      return PlatformStores::OTHER unless @website

      @website = false

      PlatformStores::WEBSITE
    end
  end

  class DecoratedProductLink
    attr_reader :product_link, :post, :store_name

    delegate :id, :url, :store, :short_code, :primary_link, :created_at, :user_id, :devices, :cache_key, :rating, :price, to: :product_link
    delegate :id, to: :post, prefix: true

    def initialize(product_link:, post:, store_name:)
      @product_link = product_link
      @post = post
      @store_name = store_name
    end

    def website_name
      URI.parse(product_link.url).host
    rescue URI::InvalidURIError
      ''
    end
  end
end
