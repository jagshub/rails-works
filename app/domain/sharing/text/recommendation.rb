# frozen_string_literal: true

module Sharing::Text
  class Recommendation
    attr_reader :user, :recommendation

    class << self
      def call(recommendation, user:)
        new(recommendation: recommendation, user: user).call
      end
    end

    def initialize(recommendation:, user:)
      @recommendation = recommendation
      @user = user
    end

    def call
      Twitter::Message
        .new
        .add_mandatory(message_beginning)
        .add_mandatory("\n\nCheck out #{ recommendation.recommended_product.name_with_fallback }:", leading_space: false)
        .add_mandatory(Routes.recommendation_url(recommendation))
        .to_s
    end

    private

    def message_beginning
      product_request_user = recommendation.product_request.user
      title = recommendation.product_request.title

      return "I asked: #{ title }" if product_request_user == user
      return "💬 @#{ product_request_user.twitter_username } asked: #{ title }" if product_request_user.twitter_username.present?

      "#{ title } 🤔"
    end
  end
end
