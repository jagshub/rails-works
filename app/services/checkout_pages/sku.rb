# frozen_string_literal: true

module CheckoutPages
  class Sku
    attr_reader :id
    delegate :price, to: :find

    def initialize(id)
      @id = id
    end

    def exists?
      find.present?
    rescue Stripe::InvalidRequestError
      false
    end

    private

    def find
      @find ||= Stripe::SKU.retrieve(id)
    end
  end
end
