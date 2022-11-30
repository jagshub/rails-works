# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::MessagesResolver < Graph::Resolvers::BaseSearch
  scope { ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object) ? object.messages.by_created_at : UpcomingPageMessage.none }

  option :draft, type: Boolean, with: :apply_draft_filter

  type Graph::Types::UpcomingPageMessageType.connection_type, null: false

  private

  def apply_draft_filter(scope, value)
    state = if value
              UpcomingPageMessage.states[:draft]
            else
              [UpcomingPageMessage.states[:sent], UpcomingPageMessage.states[:paused]]
            end
    scope.where(state: state)
  end
end
