# frozen_string_literal: true

module GoldenKitty::Policy
  extend KittyPolicy
  extend self

  can %i(create_vote destroy_vote), GoldenKitty::Finalist do |user, finalist|
    finalist.golden_kitty_category.voting_enabled?(user)
  end

  can %i(create_comment destroy), GoldenKitty::Nominee do |user, nominee|
    nominee.user == user
  end
end
