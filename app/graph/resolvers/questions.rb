# frozen_string_literal: true

module Graph::Resolvers
  class Questions < Graph::Resolvers::Base
    type Graph::Types::QuestionType.connection_type, null: false

    argument :post_id, ID, required: false

    def resolve(inputs = {})
      return ::Question.with_post(inputs[:post_id]) if inputs[:post_id].present?

      ::Question.order(title: :asc)
    end
  end
end
