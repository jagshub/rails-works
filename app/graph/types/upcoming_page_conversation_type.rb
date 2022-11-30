# frozen_string_literal: true

module Graph::Types
  class UpcomingPageConversationType < BaseObject
    graphql_name 'UpcomingPageConversation'

    extend Graph::Utils::AuthorizeRead

    field :id, ID, null: false
    field :messages, resolver: Graph::Resolvers::UpcomingPages::Conversations::MessagesResolver, null: false
    field :body, String, null: false
    field :subscriber, Graph::Types::UpcomingPageSubscriberType, null: true
    field :last_message_sent_at, Graph::Types::DateTimeType, null: true
    field :seen, Boolean, method: :seen?, null: false

    association :upcoming_page_message, Graph::Types::UpcomingPageMessageType, null: false
  end
end
