# frozen_string_literal: true

module Stream
  class Activities::PostHunted < Activities::Base
    verb 'post-hunt'
    batch_if_occurred_within 8.hours
    create_when :new_target

    target &:subject
    actors { |_event, target| [target.user] }
    connecting_text { |_receiver_id, _post, _target| 'hunted' }
    last_occurrence_at { |_object, target| target.featured_at }

    notify_user_ids do |_event, target, actor|
      return [] unless target.featured?
      return [] if target.makers.include? actor

      actor.followers.visible.non_spammer.pluck(:id)
    end
  end
end
