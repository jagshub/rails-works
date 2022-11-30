# frozen_string_literal: true

class Graph::Resolvers::Products::PostsByUsernameResolver < Graph::Resolvers::Base
  type Graph::Types::PostType.connection_type, null: true

  argument :made_by, String, required: true

  def resolve(made_by:)
    Graph::Common::BatchLoaders::Products::PostsByUsername.for(made_by).load(object)
  end
end
