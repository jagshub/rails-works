# frozen_string_literal: true

module Graph::Types
  class FlagType < BaseObject
    class ReasonEnumType < BaseEnum
      graphql_name 'FlagReasonEnum'

      Flag.reasons.each do |reason, _k|
        value reason, reason.humanize
      end
    end

    class SubjectUnionType < BaseUnion
      graphql_name 'FlagSubjectUnion'

      possible_types(
        Graph::Types::CommentType,
        Graph::Types::ReviewType,
        Graph::Types::PostType,
        Graph::Types::UserType,
        Graph::Types::ProductType,
        Graph::Types::Team::InviteType,
        Graph::Types::Team::RequestType,
      )
    end

    association :subject, SubjectUnionType, null: false
    association :user, UserType, null: true

    field :id, ID, null: false
    field :reason, ReasonEnumType, null: false
    field :other_flags_count, Int, null: false
    field :created_at, DateTimeType, null: false
  end
end
