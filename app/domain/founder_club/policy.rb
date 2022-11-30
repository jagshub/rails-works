# frozen_string_literal: true

module FounderClub::Policy
  extend KittyPolicy
  extend self

  can :claim, FounderClub::Deal do |user, deal|
    deal.active? && ::FounderClub.active_subscription?(user: user)
  end

  can %i(create destroy), :referral do |user|
    ::FounderClub.active_subscription?(user: user)
  end
end
