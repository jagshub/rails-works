# frozen_string_literal: true

class Graph::Resolvers::Search::PostResolver < Graph::Resolvers::Base
  type Graph::Types::Search::PostConnectionType, null: false

  argument :query, String, required: true
  argument :trend, Boolean, required: false
  argument :featured, Boolean, required: false
  argument :show_sunset, Boolean, required: false
  argument :posted_after, String, required: false
  argument :topics, [String], required: false
  argument :maker, String, required: false

  def resolve(query:, **options)
    Search.query_post(query, **options) do |body|
      # TODO(DZ): Use context.query.fragments to grab presence of aggregations
      # context.query.fragments['PostSearchSidebarFragment']
      #   .selections.find { |s| s.name == 'aggregations' }
      #   .selections.find { |s| s.name == 'topics' }
      Search.append_topics_aggs(body)
    end
  end
end
