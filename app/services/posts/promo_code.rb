# frozen_string_literal: true

class Posts::PromoCode
  attr_reader :text, :code, :expire_at

  class << self
    def for_post(post, ignore_expiration: false)
      return if post.blank? || post.promo_code.blank?
      return unless ignore_expiration || post.promo_expire_at.blank? || post.promo_expire_at.future?

      new(
        text: post.promo_text,
        code: post.promo_code,
        expire_at: post.promo_expire_at,
      )
    end
  end

  def initialize(text:, code:, expire_at:)
    @text = text
    @code = code
    @expire_at = expire_at
  end
end
