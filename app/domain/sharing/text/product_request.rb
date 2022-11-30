# frozen_string_literal: true

module Sharing::Text
  class ProductRequest
    attr_reader :product_request, :user

    class << self
      def call(product_request, user:)
        new(product_request: product_request, user: user).call
      end
    end

    def initialize(product_request:, user:)
      @product_request = product_request
      @user = user
    end

    def call
      Twitter::Message
        .new
        .add_mandatory(message_beginning)
        .add_mandatory('asked a question on @ProductHunt')
        .add_mandatory(message_call_to_action, leading_space: false)
        .add_mandatory(Routes.product_request_url(product_request))
        .to_s
    end

    private

    def message_call_to_action
      return "\n\nAdd your answer here:" if product_request.advice?

      "\n\nAdd your recommendation here:"
    end

    def message_beginning
      product_request_user = product_request.user

      return 'Someone' if product_request.anonymous?
      return 'I' if product_request_user == user
      return "💬 @#{ product_request_user.twitter_username }" if product_request_user.twitter_username.present?

      product_request_user.name
    end
  end
end
