# frozen_string_literal: true

module Graph::Types
  class UpcomingPageQuestionType < BaseObject
    graphql_name 'UpcomingPageQuestion'

    extend Graph::Utils::AuthorizeRead

    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :question_type, String, null: false
    field :position_in_survey, Int, null: false
    field :include_other, Boolean, null: false
    field :required, Boolean, null: false
    field :rules, [Graph::Types::UpcomingPageQuestionRuleType], null: false
    field :options, [Graph::Types::UpcomingPageQuestionOptionType], null: false
    field :answers_count, Int, null: false

    association :survey, Graph::Types::UpcomingPageSurveyType, null: false

    def options
      object.options.not_trashed.by_created_at
    end

    def answers_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.answers.count
    end
  end
end
