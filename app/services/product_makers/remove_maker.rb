# frozen_string_literal: true

class ProductMakers::RemoveMaker
  attr_reader :maker, :user, :post

  class << self
    def call(maker:)
      new(maker: maker).call
    end
  end

  def initialize(maker:)
    @maker = maker
    @user  = maker.user
    @post  = maker.post
  end

  def call
    if maker.association?
      destroy_product_maker_association
      disapprove_maker_suggestion
    elsif maker.suggested?
      destroy_maker_suggestion
    end
  end

  private

  def destroy_product_maker_association
    maker.association.destroy!
  end

  def destroy_maker_suggestion
    maker.suggestion.destroy!
  end

  def disapprove_maker_suggestion
    return unless maker.suggested? # Note(andreasklinger): sanitycheck for legacy makers that have no suggestions

    maker.suggestion.update! approved_by_id: nil
  end
end
