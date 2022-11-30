# frozen_string_literal: true

class Ships::StripeDiscountCode
  def self.deliver_to(account)
    raise "Trials aren't allowed to receive discounts" unless eligible?(account)

    ShipMailer.stripe_discounts(account).deliver_later
    ShipStripeApplication.find_or_create_by! ship_account_id: account.id
  end

  def self.eligible?(account)
    !account.trial?
  end

  def self.for(account)
    if account.free?
      new('PHShip')
    elsif account.monthly?
      new('PHShipPro', 'pfulj', '$20k')
    else
      new('PHShipPro', 'nx72sk', '$50k')
    end
  end

  attr_reader :discount_amount

  def initialize(atlas_code, discount_code = nil, discount_amount = nil)
    @atlas_code = atlas_code
    @discount_code = discount_code
    @discount_amount = discount_amount
  end

  def discount_url?
    !!@discount_code
  end

  def discount_url
    "https://stripe.com/contact/startup-offer?code=#{ @discount_code }" if @discount_code
  end

  def atlas_url
    "https://atlas.stripe.com/invite/#{ @atlas_code }"
  end
end
