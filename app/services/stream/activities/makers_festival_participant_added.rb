# frozen_string_literal: true

module Stream
  class Activities::MakersFestivalParticipantAdded < Activities::Base
    verb 'maker-festival-register'
    create_when :new_target

    target { |event| event.subject.makers_festival_category.makers_festival_edition }
    connecting_text { |_receiver_id, _object, _target| 'registered for' }

    notify_user_ids do |_event, target, actor|
      registration_has_not_begun = target.registration.blank? || target.registration.future?
      registration_has_ended = target.registration_ended.blank? || target.registration_ended.past?
      return [] if registration_has_not_begun || registration_has_ended

      festival_participant_user_ids = MakersFestival::Participant.where(makers_festival_category: target.categories).pluck(:user_id)
      actor.followers.visible.non_spammer.pluck(:id) - festival_participant_user_ids
    end
  end
end
