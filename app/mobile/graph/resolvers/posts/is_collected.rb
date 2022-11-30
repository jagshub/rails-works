# frozen_string_literal: true

module Mobile::Graph::Resolvers
  class Posts::IsCollected < BaseResolver
    type Boolean, null: false

    def resolve
      return false unless current_user

      Graph::Common::BatchLoaders::IsCollected.for(current_user).load(object)
    end
  end
end
