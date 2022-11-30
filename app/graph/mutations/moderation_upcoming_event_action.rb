# frozen_string_literal: true

module Graph::Mutations
  class ModerationUpcomingEventAction < BaseMutation
    argument_record :upcoming_event, Upcoming::Event, required: true, authorize: :moderate
    argument :approve, Boolean, required: true

    returns Graph::Types::Upcoming::EventType

    def perform(upcoming_event:, approve:)
      ModerationLog.transaction do
        approve ? upcoming_event.approve_and_notify : upcoming_event.rejected!

        ModerationLog.create!(
          reference: upcoming_event,
          message: ModerationLog::REVIEWED_MESSAGE,
          moderator: current_user,
        )
      end

      upcoming_event
    end
  end
end
