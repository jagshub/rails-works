# frozen_string_literal: true

module API::V2::Resolvers
  class Votes::SearchResolver < BaseSearchResolver
    # NOTE(dhruvparmar372): Type needs to be explicitly set to connection_type
    # here because Member::BuildType.to_type_name fails here https://github.com/rmosolgo/graphql-ruby/blob/545a3acf885f97489c154eb63d7975228fa80a99/lib/graphql/schema/field.rb#L114
    # for some reason
    type ::API::V2::Types::VoteType.connection_type, null: false

    scope { object.votes.visible.order(created_at: :desc) }

    option :created_after, type: API::V2::Types::DateTimeType, description: 'Select Votes which were created after the given date and time.', with: :apply_created_after
    option :created_before, type: API::V2::Types::DateTimeType, description: 'Select Votes which were created before the given date and time.', with: :apply_created_before

    private

    def apply_created_after(scope, value)
      return if value.blank?

      scope.where(Vote.arel_table[:created_at].gteq(value))
    end

    def apply_created_before(scope, value)
      return if value.blank?

      scope.where(Vote.arel_table[:created_at].lteq(value))
    end
  end
end
