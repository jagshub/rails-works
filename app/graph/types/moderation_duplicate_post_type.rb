# frozen_string_literal: true

module Graph::Types
  class ModerationDuplicatePostType < BaseObject
    field :id, ID, null: false
    field :reason, String, null: false
    field :url, String, null: false
    association :user, Graph::Types::UserType, null: false
    association :post, Graph::Types::PostType, null: false
  end
end
