# frozen_string_literal: true

module Stream
  class Activities::UpcomingPageSubscribed < Activities::Base
    verb 'upcoming-page-subscribe'
    batch_if_occurred_within 8.hours
    create_when :new_target

    target { |event| event.subject&.upcoming_page }
    connecting_text { |_receiver_id, _post, _target| 'subscribed to' }

    notify_user_ids do |_event, target, actor|
      return [] unless !target.trashed? && target.promoted? && target.featured_at&.past?

      actor.followers.visible.non_spammer.pluck(:id)
    end
  end
end
