# frozen_string_literal: true

module Mobile::Graph::Resolvers
  class Users::IsFollowingViewer < BaseResolver
    type Boolean, null: false

    def resolve
      return false unless current_user

      Graph::Common::BatchLoaders::IsFollowed.for(current_user).load(object)
    end
  end
end
