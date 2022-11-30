# frozen_string_literal: true

module Graph::Types
  class UpcomingPageQuestionRuleType < BaseObject
    graphql_name 'UpcomingPageQuestionRule'

    field :id, ID, null: false
    field :question, Graph::Types::UpcomingPageQuestionType, null: false
    field :dependent_option, Graph::Types::UpcomingPageQuestionOptionType, null: false
  end
end
