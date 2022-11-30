# frozen_string_literal: true

# Note(AR): Currently, this object won't be used anywhere other than in an
# interactive console. It likely will be used if/when we manage to get
# moderators to update platform stores.
class Products::RelinkPosts
  attr_reader :product

  def self.by_slug(slug)
    new(Product.find_by!(slug: slug))
  end

  def self.by_url(url)
    product = Products::Find.by_url(url)
    raise "Couldn't find product with URL #{ url }" unless product

    new(product)
  end

  def initialize(product)
    @product = product
  end

  def call
    product.post_associations.includes(:post).each do |post_association|
      next unless %w(data_migration post_create post_update merge).include?(post_association.source)

      matching_product = Products::Find.by_url(post_association.post.primary_link.url)
      next if product == matching_product

      post = post_association.post

      # Note(AR): matching_product could be nil, in which case this would unlink it:
      Rails.logger.info "> Moving post #{ post.slug } with URL #{ post.primary_link.url }"
      Products::MovePost.call(post: post, product: matching_product, source: post_association.source)
      post.reload

      if matching_product.blank?
        Rails.logger.info "> Creating new product for post #{ post.slug }"
        matching_product = Products::Create.for_post(post)
      end

      Products::RefreshActivityEvents.new(matching_product).call
    end

    Products::RefreshActivityEvents.new(product).call
  end
end
