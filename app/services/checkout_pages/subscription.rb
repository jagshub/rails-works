# frozen_string_literal: true

module CheckoutPages
  class Subscription
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def exists?
      find.present?
    rescue Stripe::InvalidRequestError
      false
    end

    def price
      find.amount
    end

    private

    def find
      @find ||= Stripe::Plan.retrieve(id)
    end
  end
end
