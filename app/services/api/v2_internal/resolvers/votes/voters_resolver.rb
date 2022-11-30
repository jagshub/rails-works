# frozen_string_literal: true

class API::V2Internal::Resolvers::Votes::VotersResolver < Graph::Resolvers::Base
  type [Graph::Types::UserType], null: true

  def resolve
    return [] if object.nil?

    scope = object.voters

    as_seen_by = current_user

    scope = scope.merge(Vote.as_seen_by(as_seen_by))
    scope = scope.non_spammer if !as_seen_by || !Spam::User.spammer_user?(as_seen_by)
    scope = scope.order_by_friends(as_seen_by) if as_seen_by
    scope.order('votes.id DESC')
  end
end
