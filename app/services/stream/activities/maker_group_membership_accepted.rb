# frozen_string_literal: true

module Stream
  class Activities::MakerGroupMembershipAccepted < Activities::Base
    verb 'maker-group-member-accept'
    create_when :new_object

    target { |event| event.subject&.group }
    connecting_text do |_receiver_id, _member, _target|
      'accepted you in'
    end

    notify_user_ids do |event, _target, _actor|
      return [] if event.subject.blank?

      [event.subject.user_id]
    end
  end
end
