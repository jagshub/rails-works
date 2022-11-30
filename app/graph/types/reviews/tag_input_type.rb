# frozen_string_literal: true

module Graph::Types
  class Reviews::TagInputType < BaseInputObject
    graphql_name 'ReviewTagInput'

    class SentimentEnumType < BaseEnum
      graphql_name 'ReviewTagSentiment'

      ReviewTagAssociation.sentiments.each do |k, v|
        value k, v
      end
    end

    argument :tag_id, ID, required: true
    argument :sentiment, SentimentEnumType, required: true
  end
end
