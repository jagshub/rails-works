# frozen_string_literal: true

class Graph::Resolvers::Upcoming::EventsResolver < Graph::Resolvers::BaseSearch
  type Graph::Types::Upcoming::EventType.connection_type, null: false

  scope { Upcoming::Event.visible.joins(:post).order('posts.scheduled_at ASC') }
end
