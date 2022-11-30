# frozen_string_literal: true

module Stream
  class Events::UserBadgeAwarded < Events::Base
    event_name 'user_badge_awarded'
    allowed_subjects [Badges::UserAwardBadge]
    should_fanout { |event| event.subject.awarded_to_user_and_visible? }

    fanout_workers { |_event| [Stream::Activities::UserBadgeAwarded] }
  end
end
