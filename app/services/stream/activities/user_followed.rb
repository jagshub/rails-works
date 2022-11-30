# frozen_string_literal: true

module Stream
  class Activities::UserFollowed < Activities::Base
    verb 'user-follow'
    batch_if_occurred_within 8.hours
    create_when :new_target

    target { |event| event.subject&.following_user }

    connecting_text do |_receiver_id, _assoc, _target|
      'started following'
    end

    notify_user_ids do |_event, target, actor|
      return [] if target.blank?
      return [] unless actor.follows? target

      [target.id]
    end
  end
end
