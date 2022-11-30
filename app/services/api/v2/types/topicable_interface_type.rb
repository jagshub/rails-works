# frozen_string_literal: true

module API::V2::Types::TopicableInterfaceType
  include API::V2::Types::BaseInterface
  description 'An object that can have topics associated with it.'

  field :id, ID, 'ID of the object.', null: false
  field :topics, API::V2::Types::TopicType.connection_type, 'Look up topics that are associated with the object.', null: false
end
