# frozen_string_literal: true

class Reviews::Form
  include MiniForm::Model

  ATTRIBUTES = %i(
    rating
    overall_experience
    currently_using
  ).freeze

  model :review, attributes: ATTRIBUTES, save: true

  validates :rating, presence: true

  validate :ensure_overall_experience_is_requested

  alias graphql_result review

  def initialize(user:, product: nil, review: nil, review_tags: nil, request_info: {})
    review ||= Review.new user: user
    review.product = product if product.present?
    @review = review
    @user = user
    @request_info = request_info
    @review.version = Review::VERSION_WITH_RATING
    @review_tags = review_tags || []
  end

  def perform
    @review.tag_associations.reload.destroy_all
    if @review_tags.present?
      @review_tags.each do |tag|
        @review.tag_associations.create! review_tag_id: tag[:tag_id], sentiment: tag[:sentiment]
      end
    end

    perform_callbacks
  end

  def overall_experience=(overall_experience)
    @review.overall_experience = BetterFormatter.call(overall_experience, mode: :simple).presence
  end

  private

  def perform_callbacks
    return unless review.id_previously_changed?

    SpamChecks.check_review(review, @request_info)

    Stream::Events::ReviewCreated.trigger(
      user: @user,
      subject: review,
      source: :web,
      request_info: @request_info,
      payload: {
        review_subject_type: 'product',
        review_subject_id: review.product_id,
      },
    )
  end

  def ensure_overall_experience_is_requested
    return if @review.rating.nil?
    return if @review.rating > 2
    return if @review.overall_experience.present?

    errors.add :overall_experience, 'This field is required'
  end
end
