# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::Ships::Contacts::ById < Graph::Resolvers::Base
  argument :id, ID, required: false

  type Graph::Types::UpcomingPageSurveyType, null: true

  def resolve(id: nil)
    survey = UpcomingPageSurvey.find_by id: id

    return if survey.nil?
    return if survey.draft? && !ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, survey)

    survey
  end
end
