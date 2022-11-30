# frozen_string_literal: true

module Graph::Types
  class UpcomingPageQuestionOptionType < BaseObject
    graphql_name 'UpcomingPageQuestionOption'

    field :id, ID, null: false
    field :title, String, null: false
    field :answers_count, Int, null: false

    def answers_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.answers.count
    end
  end
end
