# frozen_string_literal: true

module Graph::Types
  class UpcomingPageQuestionAnswerType < BaseObject
    graphql_name 'UpcomingPageQuestionAnswer'

    field :id, ID, null: false
    field :upcoming_page_subscriber_id, ID, null: false
    field :question_id, ID, method: :upcoming_page_question_id, null: false
    field :option_id, ID, method: :upcoming_page_question_option_id, null: false
    field :created_at, Graph::Types::DateTimeType, null: false

    association :question, Graph::Types::UpcomingPageQuestionType, null: false

    association(:text, String, null: false, preload: :option, method: ->(option, obj) { option&.title || obj.freeform_text })
  end
end
