# frozen_string_literal: true

class ProductMakers::CreateMaker
  attr_reader :maker, :post, :user

  class << self
    def call(maker:)
      new(maker: maker).call
    end
  end

  def initialize(maker:)
    @maker = maker
    @post  = maker.post
    @user  = maker.user
  end

  def call
    return false if maker.association?

    create_product_maker_association

    send_maker_instructions
    send_notifications
  end

  private

  def create_product_maker_association
    association = ProductMaker.create! post: maker.post, user: maker.user
    maker.suggestion.update! product_maker_id: association.id
  end

  def send_maker_instructions
    ProductMakers::SendProductMakerInstructions.call(maker: maker)
  end

  def send_notifications
    Notifications.notify_about(kind: 'friend_product_maker', object: maker.suggestion.product_maker)
  end
end
