# frozen_string_literal: true

class Mobile::Graph::Resolvers::Notifications::ActorsResolver < Mobile::Graph::Resolvers::BaseResolver
  type [Mobile::Graph::Types::UserType], null: false

  def resolve
    return [] if object.actor_ids.empty?

    Graph::Common::BatchLoaders::Notifications::Actors.for.load(object)
  end
end
