# frozen_string_literal: true

module Stream
  class Activities::UpcomingPageLaunched < Activities::Base
    verb 'upcoming-page-launch'
    batch_if_occurred_within 8.hours
    create_when :new_target

    target &:subject
    actors { |_event, target| [target.user] }
    connecting_text { |_receiver_id, _post, _target| 'created an upcoming product' }
    last_occurrence_at { |_object, target| target.featured_at }

    notify_user_ids do |_event, target, actor|
      return [] unless !target.trashed? && target.promoted? && target.featured_at&.past?

      actor.followers.visible.non_spammer.pluck(:id)
    end
  end
end
