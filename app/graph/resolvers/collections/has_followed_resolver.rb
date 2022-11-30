# frozen_string_literal: true

class Graph::Resolvers::Collections::HasFollowedResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false if current_user.blank?

    Graph::Common::BatchLoaders::Collections::IsFollowed.for(current_user).load(object)
  end
end
