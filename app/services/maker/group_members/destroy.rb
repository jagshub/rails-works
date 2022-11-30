# frozen_string_literal: true

module Maker::GroupMembers::Destroy
  extend self

  def call(group:, user:)
    member = MakerGroupMember.find_by group: group, user: user
    return if member.blank?

    member.destroy!

    nil
  end
end
