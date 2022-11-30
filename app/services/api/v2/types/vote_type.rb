# frozen_string_literal: true

module API::V2::Types
  class VoteType < BaseObject
    description 'A vote.'

    field :id, ID, 'ID of the Vote.', null: false
    field :created_at, DateTimeType, 'Identifies the date and time when Vote was created.', null: false

    association :user, UserType, description: 'User who created the Vote.', null: false, include_id_field: true
  end
end
