# frozen_string_literal: true

module Graph::Types
  class ChangeLogType < BaseNode
    implements ShareableInterfaceType
    implements SeoInterfaceType
    implements VotableInterfaceType

    field :id, ID, null: false
    field :slug, String, null: false
    field :title, String, null: false
    field :description_md, String, null: true
    field :description_html, String, null: true
    field :date, DateTimeType, null: false
    field :major_update, Boolean, null: false

    association :media, [MediaType], preload: :media, null: false
    association :discussion, Graph::Types::Discussion::ThreadType, null: true
  end
end
