# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::SegmentsResolver < Graph::Resolvers::BaseSearch
  scope { object.segments }
end
