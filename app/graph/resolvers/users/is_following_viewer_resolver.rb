# frozen_string_literal: true

class Graph::Resolvers::Users::IsFollowingViewerResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false unless current_user

    Graph::Common::BatchLoaders::IsFollowed.for(current_user).load(object)
  end
end
