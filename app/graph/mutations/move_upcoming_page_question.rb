# frozen_string_literal: true

module Graph::Mutations
  class MoveUpcomingPageQuestion < BaseMutation
    argument_record :upcoming_page_question, UpcomingPageQuestion, required: true
    argument :direction, String, required: false

    returns Graph::Types::UpcomingPageSurveyType

    def perform(upcoming_page_question:, direction: nil)
      upcoming_page = upcoming_page_question.survey.upcoming_page

      ApplicationPolicy.authorize!(current_user, :ship_surveys, upcoming_page)

      if direction == 'up'
        upcoming_page_question.move_higher
      else
        upcoming_page_question.move_lower
      end

      upcoming_page_question.refresh_rules

      upcoming_page_question.survey
    end
  end
end
