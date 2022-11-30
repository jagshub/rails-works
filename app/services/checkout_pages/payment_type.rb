# frozen_string_literal: true

module CheckoutPages
  module PaymentType
    extend self

    def new(checkout_page)
      if checkout_page.subscription?
        CheckoutPages::Subscription.new(checkout_page.sku)
      elsif checkout_page.one_time_payment?
        CheckoutPages::Sku.new(checkout_page.sku)
      else
        raise "Invalid checkout page kind - #{ checkout_page.kind }"
      end
    end
  end
end
