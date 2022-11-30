# frozen_string_literal: true

class API::V2Internal::Resolvers::Posts::ExternalPostsSearchResolver < Graph::Resolvers::Base
  argument :featured, Boolean, default_value: false, required: false
  argument :includeNoLongerAvailable, Boolean, default_value: false, required: false
  argument :postedBy, String, required: false
  argument :postedDate, String, required: false
  argument :query, String, default_value: '', required: false
  argument :topicNames, [String], default_value: [], required: false

  def resolve(args = {})
    return [] if args[:query].empty?

    # NOTE(DZ): Support v2_internal (legacy mobile app)
    Search.query_post(args[:query])
  end
end
