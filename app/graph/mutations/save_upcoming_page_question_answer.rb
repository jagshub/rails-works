# frozen_string_literal: true

module Graph::Mutations
  class SaveUpcomingPageQuestionAnswer < BaseMutation
    argument :upcoming_page_subscriber_id, ID, required: true
    argument :upcoming_page_question_id, ID, required: true
    argument :upcoming_page_question_options_ids, [ID], required: true
    argument :upcoming_page_question_freeform_text, String, required: false
    argument :other_selected, Boolean, required: false

    def perform(inputs)
      question = UpcomingPageQuestion.find(inputs[:upcoming_page_question_id])
      subscriber = question.survey.upcoming_page.subscribers.find(inputs[:upcoming_page_subscriber_id])

      if UpcomingPages::Surveys::SaveAnswer.call(question: question, subscriber: subscriber, inputs: inputs)
        success
      else
        error :base, :invalid
      end
    end
  end
end
