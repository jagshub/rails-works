# frozen_string_literal: true

class Mobile::Graph::Resolvers::HasAnsweredPoll < Mobile::Graph::Resolvers::BaseResolver
  type Boolean, null: false

  def resolve
    user = current_user
    return false if user.blank?

    Graph::Common::BatchLoaders::Poll::HasAnswered.for(user).load(object)
  end
end
