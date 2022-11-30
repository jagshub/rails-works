# frozen_string_literal: true

module Graph::Types
  class SimpleCastEpisodeType < BaseObject
    graphql_name 'SimpleCastEpisode'

    field :name, String, null: false
    field :cover_art_url, String, null: false
    field :url, String, null: false
  end
end
