# frozen_string_literal: true

module Graph::Mutations
  class SubscriptionTopicUnfollow < BaseMutation
    argument_record :topic, Topic, required: true

    returns Graph::Types::TopicType

    require_current_user

    def perform(topic:)
      Subscribe.unsubscribe(topic, current_user)

      topic
    end
  end
end
