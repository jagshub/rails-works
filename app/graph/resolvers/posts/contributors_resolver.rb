# frozen_string_literal: true

class Graph::Resolvers::Posts::ContributorsResolver < Graph::Resolvers::Base
  type [Graph::Types::PostContributorType], null: false

  argument :limit, Integer, required: true

  def resolve(limit:)
    return if object.blank?

    hunter = object.user
    result = [{ role: 'hunter', user: hunter }]
    limit -= 1

    makers = object.makers.to_a
    if makers.include?(hunter)
      result[0][:role] = 'hunter_and_maker'
      makers.delete(hunter)
    end

    limit -= makers.length
    result += makers.map { |user| { role: 'maker', user: user } }
    excluded_ids = [hunter.id, *makers.pluck(:id)].uniq

    # Note(AR): This will always return *all* makers, regardless of limit, but
    # the limit should always be quite higher than the maker count anyway.
    return result if limit <= 0

    excluded_ids << context[:current_user].id if context[:current_user]

    commenters = User.limit(limit).where.not(id: excluded_ids).where(id: object.commenters)
    commenters = commenters.order_by_friends(current_user) if current_user
    commenters = commenters.by_follower_count
    commenters = commenters.to_a

    limit -= commenters.length
    result += commenters.map { |user| { role: 'commenter', user: user } }
    excluded_ids += commenters.pluck(:id)

    return result if limit <= 0

    upvoters = User.limit(limit).where.not(id: excluded_ids).where(id: object.voters.credible)
    upvoters = upvoters.order_by_friends(current_user) if current_user
    upvoters = upvoters.by_follower_count
    upvoters = upvoters.to_a

    result += upvoters.map { |user| { role: 'upvoter', user: user } }
    result
  end
end
