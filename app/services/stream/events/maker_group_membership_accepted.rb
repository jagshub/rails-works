# frozen_string_literal: true

module Stream
  class Events::MakerGroupMembershipAccepted < Events::Base
    allowed_subjects [MakerGroupMember]
    allowed_keys_in_payload %i(maker_group_id)

    should_fanout do |event|
      member = event.subject
      return false unless member&.accepted?

      member.group&.protected_access? || member.group&.private_access?
    end

    fanout_workers { |_event| [Stream::Activities::MakerGroupMembershipAccepted] }
  end
end
