# frozen_string_literal: true

module Graph::Types
  class PostPromoType < BaseObject
    field :text, String, null: false
    field :code, String, null: false
    field :expire_at, Graph::Types::DateTimeType, null: true
  end
end
