# frozen_string_literal: true

class Graph::Resolvers::Votes::NotableVotersResolver < Graph::Resolvers::Base
  type [Graph::Types::UserType], null: false

  def resolve(args = {})
    return [] if object.nil?

    as_seen_by = current_user
    object_type = object.class.name
    cache_key = "#{ object_type }_#{ object.id }_notable_voters_order_for_generic_#{ as_seen_by&.id || 0 }_#{ object.updated_at.to_i }"
    Rails.cache.fetch(cache_key, expires_in: 1.hour.from_now) do
      scope = object.voters
      scope = scope.merge(Vote.as_seen_by(as_seen_by))
      scope = scope.non_spammer if !as_seen_by || !Spam::User.spammer_user?(as_seen_by)
      scope = scope.above_credible_karma_min

      scope = scope.order_by_friends(as_seen_by) if as_seen_by
      scope = scope.order(karma_points: :desc)

      first = args.present? ? [args[:first] || 0, 0].max : 50
      scope = scope.order('votes.credible DESC, votes.id DESC').limit([first, 50].min)
      scope
    end
  end
end
