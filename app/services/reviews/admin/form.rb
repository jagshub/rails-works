# frozen_string_literal: true

class Reviews::Admin::Form < Admin::BaseForm
  ATTRIBUTES = %i(
    product_id
    post_id
    user_id
    sentiment
    rating
    score_multiplier
    overall_experience
    currently_using
  ).freeze

  TAG_ASSOCIATIONS_ATTRIBUTES = %i(
    id
    review_id
    review_tag_id
    sentiment
    _destroy
  ).freeze

  model(
    :review,
    attributes: ATTRIBUTES,
    nested_attributes: {
      tag_associations: TAG_ASSOCIATIONS_ATTRIBUTES,
    },
    read: %i(score),
    save: true,
  )

  main_model :review, Review

  validates :rating, presence: true

  def initialize(review = Review.new)
    @review = review
  end

  def user_id=(id)
    @review.user_id = id
  end
end
