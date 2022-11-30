# frozen_string_literal: true

module API::V2::Policy
  extend KittyPolicy
  extend self

  can :update, Goal do |user, goal|
    goal.user_id == user.id
  end

  can :read, MakerGroup do |user, maker_group|
    MakerGroupMember.where(user: user, group: maker_group, state: :accepted).any?
  end
end
