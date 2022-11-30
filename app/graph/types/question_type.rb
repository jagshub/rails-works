# frozen_string_literal: true

module Graph::Types
  class QuestionType < BaseNode
    graphql_name 'Question'

    implements Graph::Types::SeoInterfaceType

    field :title, String, null: false
    field :answer, String, null: false
    field :slug, String, null: false
    field :post, Graph::Types::PostType, null: false
    field :related_questions, [Graph::Types::QuestionType], null: false
    field :updated_at, Graph::Types::DateTimeType, null: false

    def related_questions
      Questions.related_to(object)
    end
  end
end
