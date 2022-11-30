# frozen_string_literal: true

class Graph::Resolvers::Polls::HasAnsweredResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false if current_user.blank?

    Graph::Common::BatchLoaders::Poll::HasAnswered.for(current_user).load(object)
  end
end
