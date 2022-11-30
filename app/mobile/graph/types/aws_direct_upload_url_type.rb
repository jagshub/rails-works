# frozen_string_literal: true

module Mobile::Graph::Types
  class AWSDirectUploadUrlType < BaseNode
    field :uuid, String, null: true
    field :presigned_url, String, null: true
    field :public_url, String, null: true
    field :filename, String, null: true
    field :error, String, null: true
  end
end
