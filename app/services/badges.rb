# frozen_string_literal: true

module Badges
  extend self

  TOPICS_ALLOW_LIST = [
    267, # Developer Tools
    44,  # Design Tools
    46,  # Productivity
    164, # Marketing
    501, # web3
    268, # AI
    94,  # Fintech
    93,  # UX
    237, # SaaS
    43,  # Health & Fitness
    204, # Education
  ].freeze

  def generate_top_post_daily_rank(date)
    parsed_date = parsed_date(date)
    start_time = parsed_date.beginning_of_day
    end_time = parsed_date.end_of_day

    posts = top_posts_between(start_time, end_time).order('daily_rank ASC').limit(5)
    create_top_post_badges(posts, 'daily')
  end

  def generate_top_post_weekly_rank(date)
    parsed_date = parsed_date(date)
    start_time = parsed_date.beginning_of_week
    end_time = parsed_date.end_of_week

    posts = top_posts_between(start_time, end_time).order('weekly_rank ASC').limit(5)
    create_top_post_badges(posts, 'weekly')
  end

  def generate_top_post_monthly_rank(date)
    parsed_date = parsed_date(date)
    start_time = parsed_date.beginning_of_month
    end_time = parsed_date.end_of_month

    posts = top_posts_between(start_time, end_time).order('monthly_rank ASC').limit(5)
    create_top_post_badges(posts, 'monthly')
  end

  def generate_top_post_topic_weekly_rank(date)
    parsed_date = parsed_date(date)
    TOPICS_ALLOW_LIST.each do |topic_id|
      posts = top_posts_between(parsed_date.beginning_of_week, parsed_date.end_of_week).in_topic(topic_id).limit(5)
      create_top_post_topic_badges(posts, 'weekly', topic_id)
    end
  end

  def generate_top_post_topic_monthly_rank(date)
    parsed_date = parsed_date(date)
    TOPICS_ALLOW_LIST.each do |topic_id|
      posts = top_posts_between(parsed_date.beginning_of_month, parsed_date.end_of_month).in_topic(topic_id).limit(5)
      create_top_post_topic_badges(posts, 'monthly', topic_id)
    end
  end

  private

  def top_posts_between(start_date, end_date)
    Post.featured.not_excluded_from_ranking.between_dates(start_date, end_date)
  end

  def create_top_post_badges(posts, period)
    posts.each_with_index do |post, index|
      create_top_post_badge(post, period, index + 1)
    end
  end

  def create_top_post_topic_badges(posts, period, topic_id)
    posts.each_with_index do |post, index|
      create_top_post_topic_badge(post, period, index + 1, topic_id)
    end
  end

  def create_top_post_badge(post, period, position)
    badge = Badges::TopPostBadge.with_data(position: position, period: period, date: post.featured_at.to_date).first

    if badge
      badge.update! subject: post
      return badge
    end

    Badges::TopPostBadge.create subject: post, position: position, period: period, date: post.featured_at.to_date
  end

  def create_top_post_topic_badge(post, period, position, topic_id)
    topic_name = post.topics.where(id: topic_id).first.name
    badge = Badges::TopPostTopicBadge.with_data(position: position, period: period, date: post.featured_at.to_date, topic_name: topic_name).first
    if badge
      badge.update! subject: post
      return badge
    end

    Badges::TopPostTopicBadge.create! subject: post, position: position, period: period, date: post.featured_at.to_date, topic_name: topic_name
  end

  def parsed_date(date)
    case date
    when String then DateTime.strptime(date, '%Y-%m-%d %H:%M:%S')
    when Date then date
    when Time then date
    else raise "Unable to parse date, must be Date or String of format '%Y-%m-%d %H:%M:%S'"
    end
  end
end
