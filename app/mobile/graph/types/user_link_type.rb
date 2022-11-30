# frozen_string_literal: true

module Mobile::Graph::Types
  class UserLinkKindEnum < Mobile::Graph::Types::BaseEnum
    Users::Link.kinds.each do |k, v|
      value k, v
    end
  end

  class UserLinkType < BaseNode
    field :name, String, null: false
    field :url, String, null: false
    field :kind, UserLinkKindEnum, null: false
    association :user, Mobile::Graph::Types::UserType, null: false
  end
end
