# frozen_string_literal: true

module Graph::Types
  class Badges::UserBadgeAwardType < BaseNode
    field :kind, Badges::UserBadgeAwardKindType, null: false
    field :name, String, null: false
    field :description, String, null: false
    field :image_uuid, String, null: false

    def kind
      object.identifier
    end
  end
end
