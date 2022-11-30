# frozen_string_literal: true

class Graph::Resolvers::Topics::HasFollowedResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false if current_user.blank?

    Graph::Common::BatchLoaders::Topics::IsFollowed.for(current_user).load(object)
  end
end
