# frozen_string_literal: true

module API::V2Internal::Types
  class ActivityItemTarget < BaseUnion
    graphql_name 'ActivityItemTarget'

    possible_types(
      API::V2Internal::Types::PostType,
      API::V2Internal::Types::UserType,
      API::V2Internal::Types::CommentType,
    )
  end
end

module API::V2Internal::Types
  class ActivityItemType < BaseObject
    graphql_name 'ActivityItem'

    field :id, ID, null: false
    field :target, API::V2Internal::Types::ActivityItemTarget, null: false
    field :actors, [API::V2Internal::Types::UserType], null: false
    field :happend_at, API::V2Internal::Types::DateTimeType, method: :last_occurrence_at, null: false
    field :emoji, String, null: true
    field :title, String, null: false

    def title
      title = []
      title << "**#{ object.actors[0].name }**" unless object.actors.empty?
      title << "+ #{ object.actors.size - 1 } #{ 'other'.pluralize(object.actors.size - 1) }" if object.actors.size > 1
      title << object.connecting_text
      title << (object.receiver_id == object.target_id && object.target_type == 'User' ? 'you' : "**#{ object.data['target']['title'] }**") if object.data['target']
      title.join(' ')
    end
  end
end
