# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::Surveys::RespondentResolver < Graph::Resolvers::Base
    argument :id, ID, required: false

    type Graph::Types::UpcomingPageSubscriberType, null: true

    def resolve(id: nil)
      return unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object)

      object.subscribers.find_by('upcoming_page_subscribers.id' => id)
    end
  end
end
