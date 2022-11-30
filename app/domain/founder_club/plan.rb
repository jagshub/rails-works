# frozen_string_literal: true

class FounderClub::Plan
  attr_reader :plan, :discount

  def initialize(discount: nil)
    @plan = Payment::Plan.active.from_project(:founder_club).reverse_chronological.first
    @discount = discount if @plan&.discounts&.exists?(discount&.id)
  end

  class << self
    def for_discount_code(discount_code)
      if discount_code.present?
        new(discount: find_discount_by(discount_code))
      else
        new
      end
    end

    private

    def find_discount_by(code)
      access_request = FounderClub::AccessRequest.find_by(invite_code: code)
      return access_request.payment_discount_with_fallback if access_request.present?

      discount = Payment::Discount.active.find_by(code: code)
      return discount if discount.present?

      nil
    end
  end
end
