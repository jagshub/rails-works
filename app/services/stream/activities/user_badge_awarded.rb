# frozen_string_literal: true

module Stream
  class Activities::UserBadgeAwarded < Activities::Base
    verb 'user-badge-awarded'
    create_when :new_target
    solo_event? { true }

    target(&:subject)

    connecting_text do |_receiver_id, _assoc, _target|
      'You have earned a new badge:'
    end

    notify_user_ids do |_event, _target, actor|
      [actor.id]
    end
  end
end
