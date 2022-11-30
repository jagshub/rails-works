# frozen_string_literal: true

class Graph::Resolvers::Notifications::ActorsResolver < Graph::Resolvers::Base
  type [Graph::Types::UserType], null: false

  def resolve
    return [] if object.actor_ids.empty?

    Graph::Common::BatchLoaders::Notifications::Actors.for.load(object)
  end
end
