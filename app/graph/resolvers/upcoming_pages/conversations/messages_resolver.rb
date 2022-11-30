# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::Conversations::MessagesResolver < Graph::Resolvers::Base
  type [Graph::Types::UpcomingPageConversationMessageType], null: false

  def resolve
    object.messages.by_date
  end
end
