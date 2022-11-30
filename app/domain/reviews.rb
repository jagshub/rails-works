# frozen_string_literal: true

module Reviews
  extend self

  def suggested_products(user_id:, limit: nil, offset: 0)
    Reviews::SuggestedProducts.call(user_id: user_id, limit: limit, offset: offset)
  end

  def clean_suggested_products_cache(user_id:)
    Reviews::SuggestedProductsCache.clear(user_id: user_id)
  end
end
