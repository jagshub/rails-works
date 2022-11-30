# frozen_string_literal: true

module Stream
  class Activities::DiscussionStarted < Activities::Base
    verb 'discussion-start'
    create_when :new_target

    target &:subject
    connecting_text { |_receiver_id, _post, _target| 'started a discussion' }

    notify_user_ids do |_event, target, actor|
      return [] if target.trashed? || target.hidden?

      actor.followers.visible.non_spammer.pluck(:id)
    end
  end
end
