# frozen_string_literal: true

module Graph::Types
  class ModerationReasonType < BaseObject
    graphql_name 'ModerationReason'

    field :moderator, Graph::Types::UserType, null: true
    field :reason, String, null: true
  end
end
