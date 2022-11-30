# frozen_string_literal: true

module Graph::Types
  class SpamManualLogActivityType < BaseEnum
    graphql_name 'SpamManualLogActivityEnum'

    Spam::ManualLog.subject_graph_types.each do |activity|
      value activity
    end
  end
end
