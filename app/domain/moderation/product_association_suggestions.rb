# frozen_string_literal: true

module Moderation::ProductAssociationSuggestions
  extend self

  def call(product)
    associated_product_ids = product.associated_product_ids

    Products::ProductAssociation
      .select('DISTINCT associated_product_id')
      .where(product_id: associated_product_ids)
      .where.not(associated_product_id: associated_product_ids + [product.id])
      .includes(:associated_product)
      .limit(20)
      .map(&:associated_product)
  end
end
