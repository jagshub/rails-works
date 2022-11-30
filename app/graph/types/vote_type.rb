# frozen_string_literal: true

module Graph::Types
  class VoteType < BaseNode
    association :subject, VotableInterfaceType, null: false
    association :user, UserType, null: false
  end
end
