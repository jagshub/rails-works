# frozen_string_literal: true

module Graph::Types
  class PostDraftType < BaseObject
    field :id, ID, null: false
    field :uuid, String, null: false
    field :data, JsonType, null: false
    field :updated_at, DateTimeType, null: true
  end
end
