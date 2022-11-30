# frozen_string_literal: true

module Mobile::Graph::Mutations
  class TopicFollow < BaseMutation
    argument_record :topic, Topic, required: true

    returns Mobile::Graph::Types::TopicType

    require_current_user

    def perform(topic:)
      Subscribe.subscribe(topic, current_user)

      topic
    end
  end
end
