# frozen_string_literal: true

module Posts::ReviewRating
  extend self

  MAXIMUM = 5.0
  NEUTRAL = 3.5
  MINIMUM = 1.0

  def star_rating(reviewable)
    sentiment_based_rating = sentiment_rating(reviewable)
    star_ratings = reviewable.reviews.not_hidden.where.not(rating: nil)

    average =
      if sentiment_based_rating.zero?
        star_ratings.average(:rating) || 0
      else
        (sentiment_based_rating + star_ratings.sum(:rating)) / (star_ratings.count + 1).to_f
      end

    average.round(2)
  end

  def sentiment_rating(reviewable)
    positive = reviewable.reviews.with_sentiment.not_hidden.positive.count
    negative = reviewable.reviews.with_sentiment.not_hidden.negative.count
    neutral = reviewable.reviews.with_sentiment.not_hidden.neutral.count

    total = (positive + negative).to_f

    return (neutral.zero? ? 0 : NEUTRAL) if total.zero?

    (MINIMUM + (positive / total) * (MAXIMUM - MINIMUM)).round(2)
  end

  def rating_specific_count(reviewable)
    grouped_ratings_count = reviewable.reviews.group(:rating).size

    (1..MAXIMUM).map do |rating|
      { rating: rating, count: grouped_ratings_count.fetch(rating, 0) }
    end.reverse
  end
end
