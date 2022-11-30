# frozen_string_literal: true

module Reviews::SuggestedProductsCache
  extend self

  def fetch(user_id:)
    return Rails.cache.read(cache_key(user_id)) unless block_given?

    Rails.cache.fetch(cache_key(user_id), expires_in: 1.hour) do
      yield
    end
  end

  # Note(Denys): Clean up the cache when an action changing the resulting records number is performed.
  def clear(user_id:)
    Rails.cache.delete(cache_key(user_id))
  end

  private

  def cache_key(user_id)
    "reviews/suggested_products/#{ user_id }/total_count"
  end
end
