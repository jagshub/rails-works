# frozen_string_literal: true

module Maker::Policy
  extend KittyPolicy
  extend self

  can :maintain, MakerGroup do |user, group|
    maker_group_owner? user, group
  end

  can :create_discussion, MakerGroup do |user, _edition|
    user.admin? || user.verified_legit_user? && !user.company?
  end

  can :update_participant, MakerGroup do |user, participant|
    user.id == participant.user_id
  end

  can :create, MakerGroupMember do |user|
    !user.potential_spammer? && !user.spammer? && !user.company?
  end

  can :maintain, MakerGroupMember do |user, member|
    maker_group_owner? user, member.group
  end

  can :participate, :ios_beta do |user, _|
    user.admin? || MakerGroupMember.accepted.exists?(
      user: user,
      group: MakerGroup.ios_beta,
    )
  end

  can :participate, :android_beta do |user, _|
    user.admin? || MakerGroupMember.accepted.exists?(
      user: user,
      group: MakerGroup.android_beta,
    )
  end

  private

  def maker_group_owner?(user, group)
    Maker::Groups.member? group, user: user, role: :owner
  end
end
