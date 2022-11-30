# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::ConversationResolver < Graph::Resolvers::Base
    argument :id, ID, required: false

    type Graph::Types::UpcomingPageConversationType, null: false

    def resolve(id: nil)
      object.conversations.not_trashed.find_by id: id
    end
  end
end
