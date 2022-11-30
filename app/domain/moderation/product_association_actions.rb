# frozen_string_literal: true

module Moderation::ProductAssociationActions
  extend self

  def remove(by:, product:, associated_product:)
    ActiveRecord::Base.transaction do
      Products::ProductAssociation
        .where(product: product, associated_product: associated_product)
        .destroy_all
      Products::ProductAssociation
        .where(product: associated_product, associated_product: product)
        .destroy_all
    end

    log by: by, product: product, associated_product: associated_product, message: 'Removed an associated product', color: :red
  end

  def add(by:, product:, associated_product:, relationship: nil)
    return if product == associated_product

    ActiveRecord::Base.transaction do
      HandleRaceCondition.call do
        product_relation_exists =
          Products::ProductAssociation.exists?(
            product: product,
            associated_product: associated_product,
          )

        product_reverse_relation_exists =
          Products::ProductAssociation.exists?(
            product: associated_product,
            associated_product: product,
          )

        unless product_relation_exists
          Products::ProductAssociation.create!(
            product: product,
            associated_product: associated_product,
            relationship: relationship,
            source: :moderation,
          )
        end

        if !product_reverse_relation_exists && relationship != 'addon'
          Products::ProductAssociation.create!(
            product: associated_product,
            associated_product: product,
            relationship: relationship,
            source: :moderation,
          )
        end
      end
    end

    log by: by, product: product, associated_product: associated_product, message: 'Added an associated product', color: :green
  end

  def update_relationship(by:, product:, associated_product:, relationship: nil)
    ActiveRecord::Base.transaction do
      Products::ProductAssociation.where(
        product: product,
        associated_product: associated_product,
      ).find_each { |r| r.update!(relationship: relationship) }

      if relationship == 'addon'
        Products::ProductAssociation.where(
          product: associated_product,
          associated_product: product,
        ).destroy_all
      else
        relation =
          Products::ProductAssociation.find_or_initialize_by(
            product: associated_product,
            associated_product: product,
          )
        source = relation.source || :moderation

        relation.update!(relationship: relationship, source: source)
      end
    end

    log by: by, product: product, associated_product: associated_product, message: 'Updated relationship of an associated product', color: :green
  end

  private

  def log(by:, product:, associated_product:, message:, color: nil)
    attachment = Moderation::Notifier.for_associated_product(
      author: by,
      product: product,
      associated_product: associated_product,
      message: message,
      color: color,
    )
    attachment.log
    attachment.notify
  end
end
