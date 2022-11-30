# frozen_string_literal: true

module Graph::Resolvers
  class Question < Graph::Resolvers::Base
    type Graph::Types::QuestionType, null: true

    argument :slug, String, required: true

    def resolve(slug:)
      ::Question.find_by_slug(slug)
    end
  end
end
