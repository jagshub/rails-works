# frozen_string_literal: true

class Mobile::Graph::Resolvers::Products::PostsByUsernameResolver < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::PostType.connection_type, null: true

  argument :made_by, String, required: true

  def resolve(made_by:)
    Graph::Common::BatchLoaders::Products::PostsByUsername.for(made_by).load(object)
  end
end
