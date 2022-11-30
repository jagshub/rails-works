# frozen_string_literal: true

module Stream
  class Activities::PostMakerListed < Activities::Base
    verb 'post-maker-list'
    create_when :new_target

    target &:subject
    connecting_text { |_receiver_id, _post, _target| 'listed you as maker of' }
    last_occurrence_at { |_object, target| target.featured_at }

    notify_user_ids do |_event, target, actor|
      return [] unless target.featured?

      target.makers.visible.non_spammer.pluck(:id) - [actor.id]
    end
  end
end
