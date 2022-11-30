# frozen_string_literal: true

module Products::WeightedReviewsRating
  extend self

  # Note(DT): Weighted rating is calculated based on the number of reviews: ratings on a higher
  # number of votes get higher weight.
  #
  # It uses the Bayesian estimation formula by IMDB: (v ÷ (v+m)) × R + (m ÷ (v+m)) × C, where:
  #     R = review rating                           = product.reviews_rating
  #     v = number of reviews for the item          = product.reviews_with_rating_count
  #     m = minimum reviews required to be listed   = 5
  #     C = average rating across the whole dataset = Product.average(:reviews_rating) = 4.61
  #
  # The formula is equivalent to (R × v + C × m) ÷ (v + m), so using the simpler one.

  MINIMUM_REVIEWS = 5

  def order(scope, fetch_reviews: false)
    if fetch_reviews
      scope = scope.left_outer_joins(:reviews).group('products.id')
      # Note(DT): We recalculate the rating here in order to get the number for a given period.
      rating_column = 'AVG(reviews.rating)'
    else
      rating_column = 'products.reviews_rating'
    end

    scope
      .select(select_clause(rating_column))
      .order('weighted_rating DESC, followers_count DESC, products.created_at DESC')
  end

  private

  def select_clause(rating_column)
    Arel.sql(<<~SQL.squish)
      products.*,
      CASE
        WHEN products.reviews_with_rating_count > 0 THEN
        (#{ rating_column } * products.reviews_with_rating_count + #{ average_reviews_rating } * #{ MINIMUM_REVIEWS }) /
          (products.reviews_with_rating_count + #{ MINIMUM_REVIEWS })
        ELSE 0
      END AS weighted_rating
    SQL
  end

  def average_reviews_rating
    Rails.cache.fetch('products/average_reviews_rating', expires_in: 1.week) do
      Product.where('reviews_with_rating_count > 0').average(:reviews_rating) || 0
    end
  end
end
