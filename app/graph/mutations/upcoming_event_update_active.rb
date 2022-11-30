# frozen_string_literal: true

# NOTE(DZ): No team membership permissions needed here. Events require confirmation
module Graph::Mutations
  class UpcomingEventUpdateActive < BaseMutation
    argument_record :upcoming_event, Upcoming::Event, required: true, authorize: :edit
    argument :active, Boolean, required: true

    returns Graph::Types::Upcoming::EventType

    require_current_user

    def perform(upcoming_event:, active:)
      upcoming_event.update!(active: active)

      upcoming_event
    end
  end
end
