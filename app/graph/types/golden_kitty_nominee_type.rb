# frozen_string_literal: true

module Graph::Types
  class GoldenKittyNomineeType < BaseNode
    field :comment, String, null: true
    field :post, Graph::Types::PostType, null: false
  end
end
