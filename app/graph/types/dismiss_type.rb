# frozen_string_literal: true

module Graph::Types
  class DismissType < BaseObject
    field :id, ID, null: false
    field :is_dismissed, Boolean, null: false
    field :dismissable_key, String, null: false
    field :dismissable_group, String, null: false
  end
end
