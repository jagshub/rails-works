# frozen_string_literal: true

module Graph::Types
  class GoldenKittyPersonType < BaseNode
    association :user, UserType, null: false
  end
end
