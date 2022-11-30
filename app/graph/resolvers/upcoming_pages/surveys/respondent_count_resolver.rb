# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::Surveys::RespondentCountResolver < Graph::Resolvers::Base
    type Int, null: false

    def resolve
      return 0 unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object)

      object.subscribers.count
    end
  end
end
