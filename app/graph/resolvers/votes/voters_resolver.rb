# frozen_string_literal: true

class Graph::Resolvers::Votes::VotersResolver < Graph::Resolvers::Base
  type Graph::Types::UserType, null: false

  def resolve(args = {})
    return [] if object.respond_to?('votes_count') && object.votes_count == 0
    return [] if object.nil?

    as_seen_by = current_user
    object_type = object.class.name
    cache_key = "#{ object_type }_#{ object.id }_voters_order_for_generic_#{ object.updated_at.to_i }"

    return User.by_ordered_ids(Rails.cache.read(cache_key)) if !as_seen_by && Rails.cache.exist?(cache_key) && !Rails.cache.read(cache_key).nil?

    scope = object.voters
    scope = scope.merge(Vote.as_seen_by(as_seen_by))
    scope = scope.non_spammer if !as_seen_by || !Spam::User.spammer_user?(as_seen_by)
    scope = scope.above_credible_karma_min if ['Post'].include?(object_type)

    scope = scope.order_by_friends(as_seen_by) if as_seen_by
    scope = order_by_commented_on(scope, object.id, object_type) if object.respond_to?('voters') && object.respond_to?('comments')
    scope = scope.order(karma_points: :desc)

    first = args.present? ? [args[:first] || 0, 0].max : 50
    scope = scope.order('votes.credible DESC, votes.id DESC').limit([first, 50].min)

    Rails.cache.write(cache_key, scope.map(&:id), expires_in: 1.hour) unless as_seen_by
    scope
  end

  private

  JOIN_STATMENT = "
    LEFT OUTER JOIN (
      SELECT DISTINCT(user_id) AS commenter_id FROM comments
      WHERE comments.subject_id = :subject_id
      AND comments.subject_type = :subject_type
    ) AS user_comment ON commenter_id = users.id
  "

  def order_by_commented_on(scope, subject_id, subject_type)
    joins = ExecSql.sanitize_sql(JOIN_STATMENT, subject_id: subject_id, subject_type: subject_type)

    scope.joins(joins).order('commenter_id nulls last')
  end
end
