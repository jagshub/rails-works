# frozen_string_literal: true

module Mobile::Graph::Types
  class PreSignedUrl < BaseNode
    field :presigned_url, String, null: true
    field :public_url, String, null: true
    field :filename, String, null: true
    field :error, String, null: true
  end
end
