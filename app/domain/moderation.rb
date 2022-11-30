# frozen_string_literal: true

module Moderation
  extend self

  def reason(post:)
    Moderation::Reason.find_by(reference: post)
  end

  def public_reason(post:)
    Moderation::Reason.find_by(reference: post, share_public: true)
  end

  def update_post(by:, post:, inputs:)
    update_post = Moderation::FeaturePost.new(post: post, moderator: by)
    update_post.update inputs
    update_post
  end

  def trash_post(by:, post:, reason:)
    Moderation::PostActions.trash(by: by, post: post, reason: reason)

    Flags.resolve_all_for record: post, moderator: by
  end

  def change_multiplier(by:, post:, multiplier:)
    Moderation::PostActions.change_multiplier(by: by, post: post, multiplier: multiplier)
  end

  def add_associated_product(by:, product:, associated_product:, relationship: nil)
    relationship ||= 'alternative'

    Moderation::ProductAssociationActions.add(
      by: by,
      product: product,
      associated_product: associated_product,
      relationship: relationship,
    )
  end

  def remove_associated_product(by:, product:, associated_product:)
    ::Moderation::ProductAssociationActions.remove(
      by: by,
      product: product,
      associated_product: associated_product,
    )
  end

  def update_associated_product(by:, product:, associated_product:, relationship:)
    ::Moderation::ProductAssociationActions.update_relationship(
      by: by,
      product: product,
      associated_product: associated_product,
      relationship: relationship,
    )
  end

  def review_post(by:, post:)
    Moderation::PostActions.review_post(by: by, post: post)
  end

  def mark_as_reviewed(by:, reference:)
    Moderation::Review.call(by: by, reference: reference)
  end

  def seo_review(by:, reference:)
    Moderation::SeoReview.call(by: by, reference: reference)
  end

  def change_locked(by:, post:, locked:)
    Moderation::PostActions.change_locked(by: by, post: post, locked: locked)
  end

  def product_association_suggestions(product:)
    Moderation::ProductAssociationSuggestions.call(product)
  end

  def comment_unhide(comment:)
    comment.unhide!
  end

  def comment_hide(comment:)
    comment.hide!
  end

  def review_unhide(review:)
    review.unhide!
  end

  def review_hide(review:)
    review.hide!
  end

  def set_user_role(user:, role:)
    raise "Invalid user role #{ role }" unless User.roles.include? role

    user.update! role: role
  end

  def policy
    Moderation::Policy
  end
end
