# frozen_string_literal: true

module Graph::Types
  class Reviews::SentimentType < BaseEnum
    graphql_name 'ReviewsSentiment'

    value 'negative'
    value 'neutral'
    value 'positive'
  end
end
