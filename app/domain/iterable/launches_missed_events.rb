# frozen_string_literal: true

module Iterable::LaunchesMissedEvents
  extend self

  CREDIBLE_VOTES_THRESHOLD = 50
  DAYS_SINCE = 14.days
  TOP_POST_TYPE = 'top_post'
  INTERESTED_POST_TYPE = 'interested_post'

  def call(user:, limit: 5, since: nil)
    raise ArgumentError, 'User is required' if user.blank?

    user_topics = user.followed_topics
    scope = post_scope(since: since)
    scope = scope.in_topic(user_topics) unless user_topics.empty?
    posts = scope.limit(limit)

    post_payloads = posts.map do |post|
      generate_interested_post_payload(post: post, type: INTERESTED_POST_TYPE, user_topics: user_topics)
    end

    # Note(JL): If there weren't enough posts in the user's followed topics, grab general top
    # posts but ensure that they don't include the list of posts that's already been pulled
    if user_topics.any? && posts.length < limit
      top_posts = recent_top_daily_posts_scope(since: since, exclude: posts.ids).limit(limit - posts.length)
      post_payloads += top_posts.map do |top_post|
        generate_payload(post: top_post.subject, type: TOP_POST_TYPE)
      end
    end

    {
      email: user.email,
      eventName: 'launches_missed',
      dataFields: {
        post_items: post_payloads,
      },
    }
  end

  private

  def post_scope(since:)
    end_date = Time.zone.yesterday.at_end_of_day
    start_date = since || end_date - DAYS_SINCE

    if start_date > end_date
      raise 'End date is earlier than start date'
    end

    # Note(JL): Distinct ensures that we don't get the same post appearing for multiple of
    # the user's followed topics.
    Post
      .includes(:topics)
      .select('distinct posts.*, posts.credible_votes_count * posts.score_multiplier')
      .between_dates(start_date, end_date)
      .where('credible_votes_count >= ?', CREDIBLE_VOTES_THRESHOLD)
      .alive
      .by_credible_votes
  end

  def recent_top_daily_posts_scope(since:, exclude: nil)
    end_date = Time.zone.yesterday.at_end_of_day
    start_date = since || end_date - DAYS_SINCE

    if start_date > end_date
      raise 'End date is earlier than start date'
    end

    Badges::TopPostBadge
      .where.not(subject_id: exclude)
      .with_period(:daily)
      .between_dates(start_date, end_date)
  end

  def generate_payload(post:, type:)
    {
      post: {
        name: post.name,
        date: post.featured_at.strftime('%B %d, %Y'),
        image: post.thumbnail_url,
        slug: post.slug,
        tagline: post.tagline,
      },
      type: type,
    }
  end

  def generate_interested_post_payload(post:, type:, user_topics:)
    post_payload = generate_payload(post: post, type: type)
    return if user_topics.empty?

    if type == INTERESTED_POST_TYPE
      # Note(JL): Since a post can be related to multiple topics, pick the first topic in post.topics that matches
      # one in the user's followed topics,
      common_topic = (user_topics & post.topics).first

      unless common_topic.nil?
        post_payload[:topic] = common_topic.name
      end
    end

    post_payload
  end
end
