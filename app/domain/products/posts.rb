# frozen_string_literal: true

module Products::Posts
  extend self

  def search_with_same_link(product, limit: 10)
    base_query(limit)
      .distinct
      .left_joins(:links)
      .merge(legacy_product_link_query(product))
  end

  def search_with_link_prefix(product, limit: 10)
    base_query(limit)
      .distinct
      .left_joins(:links)
      .merge(legacy_product_link_prefix_query(product))
  end

  def search_with_same_name(product, limit: 10)
    base_query(limit)
      .where('name ilike ?', LikeMatch.by_words(product.name))
  end

  private

  def legacy_product_link_query(product)
    LegacyProductLink.where(clean_url: product.clean_url)
  end

  def legacy_product_link_prefix_query(product)
    # NOTE(Jagadeesh): clean_url is already lowercased, see UrlParser.clean_product_url so no need for LOWER here
    LegacyProductLink
      .where('clean_url LIKE ?', LikeMatch.simple(product.clean_url))
      .where.not(clean_url: product.clean_url)
  end

  def base_query(limit)
    Post
      .not_trashed
      .featured
      .order(credible_votes_count: :desc)
      .limit(limit)
      .left_joins(:product_association)
      .where(product_post_associations: { id: nil })
  end
end
