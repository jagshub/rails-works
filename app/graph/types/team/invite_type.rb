# frozen_string_literal: true

module Graph::Types
  class Team::InviteType < BaseNode
    graphql_name 'TeamInvite'

    field :email, String, null: true
    field :code, String, null: false
    field :created_at, Graph::Types::DateTimeType, null: false

    # Note(DT): V1 doesn't support inviting users by email. Later when we are, the user field will become nullable.
    association :user, UserType, null: false
    association :referrer, UserType, null: false
    association :product, ProductType, null: false

    field :is_different_user, Boolean, null: false
    def is_different_user
      context[:current_user]&.id != object.user.id
    end

    field :status, Graph::Types::Team::InviteStatusEnum, null: false
    def status
      object.expired? ? 'expired' : object.status
    end

    field :url, String, null: false
    def url
      Routes.team_invite_url(object)
    end
  end
end
