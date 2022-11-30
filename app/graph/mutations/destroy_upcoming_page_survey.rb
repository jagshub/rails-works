# frozen_string_literal: true

module Graph::Mutations
  class DestroyUpcomingPageSurvey < BaseMutation
    argument_record :upcoming_page_survey, UpcomingPageSurvey, required: true, authorize: :destroy

    returns Graph::Types::UpcomingPageSurveyType

    def perform(upcoming_page_survey:)
      upcoming_page_survey.trash
      upcoming_page_survey
    end
  end
end
