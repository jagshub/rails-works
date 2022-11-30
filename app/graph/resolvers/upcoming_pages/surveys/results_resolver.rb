# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::Surveys::ResultsResolver < Graph::Resolvers::Base
    Result = Struct.new(:question_id, :option_id, :count)

    class ResultType < Graph::Types::BaseObject
      graphql_name 'UpcomingPageSurveyResult'

      field :question_id, ID, null: false
      field :option_id, String, null: true
      field :count, Int, null: false
    end

    type [ResultType], null: false

    argument :option_ids, [ID], required: false

    def resolve(option_ids:)
      return [] unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object)

      scope = object.answers.group(:upcoming_page_question_id, :upcoming_page_question_option_id)
      # NOTE(rstankov): We only support single option id, because UI currently handles this case
      scope = scope.where(upcoming_page_subscriber_id: UpcomingPageQuestionAnswer.where(upcoming_page_question_option_id: option_ids).pluck(:upcoming_page_subscriber_id)) if option_ids
      scope.count.map do |(set, count)|
        Result.new(set[0], set[1], count)
      end
    end
  end
end
