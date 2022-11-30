# frozen_string_literal: true

class Graph::Resolvers::Ships::PublicStats < Graph::Resolvers::Base
  class ShipPublicStats < Graph::Types::BaseObject
    graphql_name 'ShipPublicStats'

    field :subscribers_count, String, null: false
    field :pages_count, String, null: false
    field :makers_count, String, null: false
  end

  type ShipPublicStats, null: false

  def resolve
    OpenStruct.new(
      subscribers_count: Rails.configuration.settings.ship_public_stat_subscribers_count,
      pages_count: Rails.configuration.settings.ship_public_stat_pages_count,
      makers_count: Rails.configuration.settings.ship_public_stat_makers_count,
    )
  end
end
