# frozen_string_literal: true

module Maker::Groups
  extend self

  def member?(group, user:, role: nil)
    conditions = {
      group: group,
      role: role,
      user: user,
    }.compact

    MakerGroupMember.accepted.exists? conditions
  end
end
