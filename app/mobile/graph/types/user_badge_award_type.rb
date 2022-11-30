# frozen_string_literal: true

module Mobile::Graph::Types
  class UserBadgeAwardType < BaseNode
    field :kind, UserBadgeAwardKindType, null: false
    field :name, String, null: false
    field :description, String, null: false
    field :image_uuid, String, null: false

    def kind
      object.identifier
    end
  end
end
