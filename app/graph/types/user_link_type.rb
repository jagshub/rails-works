# frozen_string_literal: true

module Graph::Types
  class UserLinkKindEnum < Graph::Types::BaseEnum
    Users::Link.kinds.each do |k, v|
      value k, v
    end
  end

  class UserLinkType < BaseNode
    field :name, String, null: false
    field :url, String, null: false
    field :kind, UserLinkKindEnum, null: false
    association :user, Graph::Types::UserType, null: false
  end
end
