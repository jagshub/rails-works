# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::SurveyResolver < Graph::Resolvers::Base
    argument :id, ID, required: false
    argument :used_in_upcoming_page, Boolean, required: false

    type Graph::Types::UpcomingPageSurveyType, null: true

    def resolve(id: nil, used_in_upcoming_page: nil)
      scope = object.surveys.not_trashed

      if used_in_upcoming_page
        survey = scope.used_in_upcoming_page.first
        survey if survey&.opened?
      else
        scope = scope.visible unless ApplicationPolicy.can? current_user, ApplicationPolicy::MAINTAIN, object
        scope.find_by id: id
      end
    end
  end
end
