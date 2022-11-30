# frozen_string_literal: true

module Maker::Feed::Items
  extend self

  def call(date:, current_user:, feed_type:)
    trending_discussion = trending_query ::Discussion::Thread.visible, date

    items = feed_type == :all ? all(date, current_user, trending_discussion) : friends(date, current_user, trending_discussion)

    feed_type == :friends ? [trending_discussion].compact + items : items
  end

  private

  def all(date, current_user, trending_discussion)
    exclude_friend_items = current_user.present? && current_user.friend_count > 0

    discussions = if exclude_friend_items
                    discussion_scope(date, trending_discussion).where(exclude_friend_sql(current_user, Discussion::Thread.table_name))
                  else
                    discussion_scope(date, trending_discussion)
                  end.to_a

    get_items discussions
  end

  def friends(date, current_user, trending_discussion)
    return [] if current_user.blank? || current_user.friend_count == 0

    discussions = discussion_scope(date, trending_discussion).joins('INNER JOIN user_friend_associations on user_friend_associations.following_user_id = discussion_threads.user_id')
                                                             .where('user_friend_associations.followed_by_user_id = ?', current_user.id)
                                                             .to_a

    get_items discussions
  end

  def get_items(discussions)
    return if discussions.empty?

    size_diff = discussions.length

    discussions += [nil] * size_diff if size_diff > 0
    discussions.flatten.compact
  end

  def exclude_friend_sql(current_user, table)
    sql = UserFriendAssociation.select(:id)
                               .where("following_user_id = #{ table }.user_id")
                               .where(followed_by_user_id: current_user)
                               .to_sql

    "NOT EXISTS (#{ sql })"
  end

  def discussion_scope(date, trending_discussion)
    t = Discussion::Thread.arel_table

    scope = Discussion::Thread.where(subject_type: 'MakerGroup')
                              .includes(:user, :subject)
                              .by_credible_votes_count
                              .where(t[:created_at].gteq(date.beginning_of_day).and(t[:created_at].lteq(date.end_of_day)))
                              .approved
    scope = scope.where.not(id: trending_discussion.id) if trending_discussion.present?

    scope
  end

  def trending_query(model, date)
    model
      .where(model.arel_table[:trending_at].eq(date))
      .by_random
      .first
  end
end
