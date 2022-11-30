# frozen_string_literal: true

class ProductMakers::SendProductMakerInstructions
  attr_reader :maker, :user, :post

  class << self
    def call(maker:)
      new(maker).call
    end
  end

  def initialize(maker)
    @maker = maker
    @user  = maker.user
    @post  = maker.post
  end

  def call
    return unless maker.association?
    return unless post.featured?
    return unless first_maker? && post_within_24_hours?

    send_maker_instructions
  end

  private

  def first_maker?
    post.product_makers.count == 1
  end

  def first_time_maker?
    user.products.count == 1
  end

  def post_within_24_hours?
    post.featured_at > 1.day.ago
  end

  def send_maker_instructions
    return unless first_time_maker?
    return if user.email.blank? || !user.send_maker_instructions_email

    UserMailer.maker_instructions(user, post).deliver_later(wait: 1.minute)
  end
end
