# frozen_string_literal: true

module API::V2Internal::Types
  class PostPromoType < BaseObject
    field :text, String, null: false
    field :code, String, null: false
  end
end
