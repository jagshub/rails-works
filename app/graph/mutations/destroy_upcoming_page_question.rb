# frozen_string_literal: true

module Graph::Mutations
  class DestroyUpcomingPageQuestion < BaseMutation
    argument_record :upcoming_page_question, UpcomingPageQuestion, required: true, authorize: :maintain

    returns Graph::Types::UpcomingPageQuestionType

    def perform(upcoming_page_question:)
      upcoming_page_question.destroy!
      upcoming_page_question
    end
  end
end
