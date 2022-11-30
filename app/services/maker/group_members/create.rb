# frozen_string_literal: true

module Maker::GroupMembers::Create
  extend self

  def call(group:, user:)
    member = MakerGroupMember.find_or_initialize_by group: group, user: user
    return member if member.persisted?

    auto_accept = group.main? || group.public_access?

    member.state = auto_accept ? :accepted : :pending
    member.assessed_at = member.pending? ? nil : DateTime.current

    # NOTE(ayrton) Date objects are not serializable
    member.changes.except(:assessed_at)
    member.save!

    # NOTE(DZ): Turn off member notification for now
    # ApplicationEvents.trigger(
    #   :maker_group_member_created,
    #   member: member,
    #   member_changes: member_changes,
    # )

    member
  end
end
