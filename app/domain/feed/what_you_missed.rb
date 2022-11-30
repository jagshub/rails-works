# frozen_string_literal: true

class Feed::WhatYouMissed
  attr_reader :since, :user, :topic_ids, :limit, :override_min

  PERIOD = 14.days.freeze

  class << self
    def call(since:, user: nil, topic_ids: [], limit: 4, override_min: false)
      new(since, user, topic_ids, limit, override_min).run
    end
  end

  def initialize(since, user, topic_ids, limit, override_min)
    @since = since
    @user = user
    @topic_ids = topic_ids
    @limit = limit
    @override_min = override_min
  end

  def run
    return [] if since.present? && since > Time.zone.today.at_beginning_of_day

    scope = Post.where(featured_at: maximum_range).alive.by_credible_votes
    scope = scope.where.not(id: posts_upvoted_by_user) if user.present?
    scope = reduce_by_topic(scope) unless topic_ids.empty?
    posts = limit.nil? ? scope : scope.limit(limit)
    posts = posts.to_a

    return [] if posts.size < 2

    posts
  end

  def maximum_range
    maximum_lower_limit..maxium_upper_limit
  end

  def maximum_lower_limit
    # Note(TC): In some cases we want to get posts outside the 14 day limit. If this is the case
    # we will require a since time reference with the overrride for it to work.
    return since if override_min && since.present?

    since.present? && since > PERIOD.ago ? since : PERIOD.ago
  end

  # NOTE(naman): In any case we do not want to show posts from today as they are visbile below
  def maxium_upper_limit
    Time.zone.yesterday.at_end_of_day
  end

  # Note(andreasklinger): This is the most common nerd-user feedback we get.
  #   Happy to take the performance hit just to shut them up.
  # Note(andreasklinger): To keep performance reasonable this fetches recent votes not recent posts.
  def posts_upvoted_by_user
    user.post_votes.where('created_at > :date', date: PERIOD.ago).pluck(:subject_id)
  end

  private

  # Note (TC): When fetching by topic, we often want to fallback to a random post in the original
  # query, so we check that at least 2 posts are in result, otherwise just send the original scope
  # so there are more topics to randomly pick from.
  def reduce_by_topic(scope)
    topic_scope = scope.in_topic(topic_ids)
    return topic_scope if topic_scope.size > 2

    scope
  end
end
