# frozen_string_literal: true

class Graph::Resolvers::Moderation::UpcomingEventsResolver < Graph::Resolvers::BaseSearch
  type Graph::Types::Upcoming::EventType.connection_type, null: false

  scope do
    unapproved = Upcoming::Event.where(id: Upcoming::Event.unmoderated.pending.with_scheduled_post)
    edited = Upcoming::Event.where(id: Upcoming::Event.approved.edited_after_moderation.with_scheduled_post)

    unapproved.or(edited).order('created_at DESC')
  end
end
