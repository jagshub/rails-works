# frozen_string_literal: true

module Maker::GroupMembers
  extend self

  def accept(member, assessed_by:, source:, request_info: {})
    main_membership = create group: MakerGroup.main, user: member.user

    Maker::GroupMembers::StateChanger.call main_membership, state: :accepted, assessed_by: assessed_by
    Maker::GroupMembers::StateChanger.call member, state: :accepted, assessed_by: assessed_by

    Stream::Events::MakerGroupMembershipAccepted.trigger(
      user: assessed_by,
      subject: member,
      source: source,
      request_info: request_info,
      payload: { maker_group_id: member.group.id },
    )
  end

  def create(group:, user:)
    Maker::GroupMembers::Create.call group: group, user: user
  end

  def decline(member, assessed_by:)
    Maker::GroupMembers::StateChanger.call member, state: :declined, assessed_by: assessed_by
  end

  def destroy(group:, user:)
    Maker::GroupMembers::Destroy.call group: group, user: user
  end
end
