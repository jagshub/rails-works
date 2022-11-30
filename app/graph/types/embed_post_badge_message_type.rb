# frozen_string_literal: true

module Graph::Types
  class EmbedPostBadgeMessageType < BaseNode
    field :title, String, null: false
    field :tagline, String, null: false
    field :url, String, null: false
  end
end
