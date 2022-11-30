# frozen_string_literal: true

module Mobile::Graph::Resolvers
  class IsSubscribed < Mobile::Graph::Resolvers::BaseResolver
    type Boolean, null: false

    def resolve
      return false if current_user.blank?

      Graph::Common::BatchLoaders::SubscriptionsLoader.for(current_user).load(object)
    end
  end
end
