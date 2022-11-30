# frozen_string_literal: true

module Graph::Types
  class CommentPromptKindEnum < Graph::Types::BaseEnum
    CommentPrompt.prompts.each do |k, v|
      value k, v
    end
  end

  class CommentPromptType < BaseNode
    field :prompt, CommentPromptKindEnum, null: false
    association :post, Graph::Types::PostType, null: false
  end
end
