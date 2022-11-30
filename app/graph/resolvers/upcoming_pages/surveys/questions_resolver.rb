# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::Surveys::QuestionsResolver < Graph::Resolvers::Base
    type [Graph::Types::UpcomingPageQuestionType], null: false

    def resolve
      object.questions.by_position
    end
  end
end
