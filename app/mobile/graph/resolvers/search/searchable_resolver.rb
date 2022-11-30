# frozen_string_literal: true

class Mobile::Graph::Resolvers::Search::SearchableResolver < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::Search::ConnectionType, null: false

  argument :query, String, required: true
  argument :models, [Mobile::Graph::Types::Search::ModelEnum], required: false

  def resolve(query:, models: [])
    models = models.map { |model| models_enum_constantize(model) }
    models = Search::Searchable.models if models.empty?

    Search.query(query, models: models) do |body|
      # NOTE(DZ): There is no api currently to look up requested fields on
      # a query. For now, just append topic aggregation on all queries.
      # https://github.com/rmosolgo/graphql-ruby/issues/671
      Search.append_topics_aggs(body)
    end
  end

  def models_enum_constantize(model)
    case model
    when 'AnthologiesStory'
      Anthologies::Story
    when 'DiscussionThread'
      Discussion::Thread
    else
      model.safe_constantize
    end
  end
end
