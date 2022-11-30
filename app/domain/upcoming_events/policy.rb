# frozen_string_literal: true

module UpcomingEvents::Policy
  extend KittyPolicy
  extend self

  MINIMUM_SCHEDULE_AHEAD = 7.days

  can :view_upcoming_event_create_btn, Post do |user, post|
    post.new_product.present? && (
      user.admin? ||
      user_is_team_member?(user, post.new_product) ||
      user_is_post_maker?(user, post)
    )
  end

  can :edit, Upcoming::Event do |user, event|
    user.admin? || user_is_team_member?(user, event.product)
  end

  can :create_upcoming_event, Post do |user, post|
    post.new_product.present? && (
      user.admin? ||
      user_is_team_member?(user, post.new_product)
    )
  end

  can :create_upcoming_event, Product do |user, product|
    user.admin? || user_is_team_member?(user, product)
  end

  can :moderate, Upcoming::Event do |user, _event|
    user.admin?
  end

  private

  def user_is_team_member?(user, product)
    product.team_members.active.exists?(user: user)
  end

  def user_is_post_maker?(user, post)
    ProductMakers.maker_of?(user: user, post_id: post.id)
  end
end
