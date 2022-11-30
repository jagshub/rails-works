# frozen_string_literal: true

module API::V2::Resolvers
  class Votes::IsVotedResolver < BaseResolver
    type Boolean, null: false

    def resolve
      return false unless can_resolve_private?

      VotesLoader.for(current_user).load(object)
    end

    class VotesLoader < GraphQL::Batch::Loader
      def initialize(user)
        @user = user
      end

      def perform(subjects)
        votes = @user.votes.where(condition_for(subjects)).pluck(Arel.sql('subject_id || subject_type'))

        subjects.each do |subject|
          fulfill subject, votes.include?("#{ subject.id }#{ subject.class.name }")
        end
      end

      private

      def condition_for(subjects)
        # NOTE(rstankov): ActiveRecord doesn't have syntax for 'IN (VALUES (pair), (pair))
        values = subjects.map do |subject|
          "(#{ ActiveRecord::Base.connection.quote(subject.class.name) }, #{ subject.id.to_i })"
        end
        "(subject_type, subject_id) IN ( VALUES #{ values.join(', ') } )"
      end
    end
  end
end
