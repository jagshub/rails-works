# frozen_string_literal: true

module Graph::Resolvers
  class Posts::VotesCountResolver < Graph::Resolvers::Base
    type Int, null: false

    def resolve
      return object.votes_count if current_user.blank? || !Spam::User.sandboxed_user?(current_user)

      klass = Graph::Resolvers::Votes::HasVotedResolver
      klass.new(field: nil, object: object, context: context).resolve.then do |has_voted|
        if has_voted
          object.votes_count + 1
        else
          object.votes_count
        end
      end
    end
  end
end
