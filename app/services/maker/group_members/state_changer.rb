# frozen_string_literal: true

module Maker::GroupMembers::StateChanger
  extend self

  def call(member, state:, assessed_by:)
    return if member.state == state.to_s

    member.state = state
    member.assessed_at = member.pending? ? nil : DateTime.current
    member.assessed_by = member.pending? ? nil : assessed_by

    # NOTE(ayrton) Date objects are not serializable
    member.changes.except(:assessed_at, :assessed_by)
    member.save!

    # NOTE(DZ): Turn off member notification for now
    # ApplicationEvents.trigger(
    #   :maker_group_member_updated,
    #   member: member,
    #   member_changes: member_changes,
    # )

    nil
  end
end
