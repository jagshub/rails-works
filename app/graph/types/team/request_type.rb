# frozen_string_literal: true

module Graph::Types
  class Team::RequestType < BaseNode
    graphql_name 'TeamRequest'

    class StatusEnum < Graph::Types::BaseEnum
      graphql_name 'TeamRequestStatusEnum'

      ::Team::Request.statuses.values.each do |status_value|
        value status_value
      end
    end

    field :status, StatusEnum, null: false
    field :team_email, String, null: true
    field :team_email_confirmed, Boolean, null: false
    field :additional_info, String, null: true
    field :moderation_notes, String, null: true

    association :user, Graph::Types::UserType, null: false
    association :product, Graph::Types::ProductType, null: false
  end
end
