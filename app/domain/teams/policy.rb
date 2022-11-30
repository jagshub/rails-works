# frozen_string_literal: true

module Teams::Policy
  extend KittyPolicy
  extend self

  can :maintain, Product do |user, product|
    admin?(user) || product_owner?(user, product)
  end

  can :edit, Product do |user, product|
    admin?(user) || product_member?(user, product)
  end

  can :update, Team::Member do |user, team_member|
    can? user, :maintain, team_member.product
  end

  can :maintain, Team::Request do |user, team_request|
    can? user, :maintain, team_request.product
  end

  can :edit, Team::Request do |user, team_request|
    can? user, :edit, team_request.product
  end

  can :edit, Team::Invite do |user, team_invite|
    can? user, :edit, team_invite.product
  end

  private

  def admin?(user)
    user&.admin?
  end

  def product_owner?(user, product)
    product.team_members.active.owner.exists?(user: user)
  end

  def product_member?(user, product)
    product.team_members.active.exists?(user: user)
  end
end
