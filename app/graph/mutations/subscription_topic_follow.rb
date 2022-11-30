# frozen_string_literal: true

module Graph::Mutations
  class SubscriptionTopicFollow < BaseMutation
    argument_record :topic, Topic, required: true

    returns Graph::Types::TopicType

    require_current_user

    def perform(topic:)
      Subscribe.subscribe(topic, current_user)

      topic
    end
  end
end
