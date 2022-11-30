# frozen_string_literal: true

module Graph::Mutations
  class ShipSurveyResultsExport < BaseMutation
    argument_record :survey, UpcomingPageSurvey, required: true, authorize: ApplicationPolicy::MAINTAIN

    returns Graph::Types::UpcomingPageSurveyType

    def perform(survey:)
      Ships::Surveys::ExportResultsWorker.perform_later user: current_user, survey: survey
      survey
    end
  end
end
