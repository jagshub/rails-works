# frozen_string_literal: true

module MakersFestival::MakerGroup
  extend self

  def add_member(group:, user:)
    member = MakerGroupMember.find_or_initialize_by group: group, user: user
    return member if member.persisted?

    member.state = :accepted
    member.assessed_at = DateTime.current
    member_changes = member.changes.except(:assessed_at)
    member.save!

    ApplicationEvents.trigger(
      :maker_group_member_created,
      member: member,
      member_changes: member_changes,
    )

    member
  end
end
