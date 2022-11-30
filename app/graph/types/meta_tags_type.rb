# frozen_string_literal: true

module Graph::Types
  class MetaTagsType < BaseObject
    graphql_name 'MetaTags'

    field :canonical_url, String, null: true
    field :creator, String, null: true
    field :description, String, null: true
    field :image, String, null: true
    field :robots, String, null: true
    field :title, String, null: true
    field :type, String, null: true
    field :oembed_url, String, null: true
    field :mobile_app_url, String, null: true
    field :author, String, null: true
    field :author_url, String, null: true
  end
end
