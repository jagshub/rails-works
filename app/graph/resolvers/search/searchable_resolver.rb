# frozen_string_literal: true

class Graph::Resolvers::Search::SearchableResolver < Graph::Resolvers::Base
  type Graph::Types::Search::ConnectionType, null: false

  argument :query, String, required: true
  argument :models, [Graph::Types::Search::ModelEnum], required: false
  argument :track, Boolean, required: false

  def resolve(query:, models: [], track: false)
    models = models.map { |model| models_enum_constantize(model) }
    models = Search::Searchable.models if models.empty?

    Search.track(query, models: models, user: current_user, platform: :web) if track
    Search.query(query, models: models)
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
