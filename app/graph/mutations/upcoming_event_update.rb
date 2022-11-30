# frozen_string_literal: true

# NOTE(DZ): No team membership permissions needed here. Events require confirmation
module Graph::Mutations
  class UpcomingEventUpdate < BaseMutation
    argument_record :upcoming_event, Upcoming::Event, required: true, authorize: :edit

    argument :title, String, required: true
    argument :description, String, required: true
    argument :banner_uuid, String, required: true
    argument :banner_mobile_uuid, String, required: false

    returns Graph::Types::Upcoming::EventType

    require_current_user

    def perform(upcoming_event:, **params)
      UpcomingEvents::Form.update(
        upcoming_event: upcoming_event,
        user: current_user,
        user_edited_at: Time.current,
        **params,
      )
    end
  end
end
