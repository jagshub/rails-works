# frozen_string_literal: true

class Graph::Resolvers::IsSubscribed < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false if current_user.blank?

    Graph::Common::BatchLoaders::SubscriptionsLoader.for(current_user).load(object)
  end
end
