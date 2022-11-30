# frozen_string_literal: true

# Sends notifications when badges have been awarded
class Emails::Badges
  attr_reader :date

  def initialize(date)
    @date = date
  end

  def notify_daily_award_winners
    # grabs all of yesterday's daily badges, this runs at 3AM PST everyda
    badges_by_post = top_badges_between(:daily, @date.beginning_of_day, @date.end_of_day)
    badges_by_post.values.each do |badges|
      Notifications.notify_about(kind: 'awarded_badges', object: badges.first)
    end
  end

  def notify_weekly_award_winners
    # grabs all of last week's weekly badges, the date is past Sunday
    badges_by_post = top_badges_between(:weekly, @date.beginning_of_week, @date.end_of_week)
    badges_by_post.values.each do |badges|
      Notifications.notify_about(kind: 'awarded_badges', object: badges.first)
    end
  end

  def notify_monthly_award_winners
    # grabs all of last months's monthly badges, the date is 1st of last month
    badges_by_post = top_badges_between(:monthly, @date.beginning_of_month, @date.end_of_month)
    badges_by_post.values.each do |badges|
      Notifications.notify_about(kind: 'awarded_badges', object: badges.first)
    end
  end

  private

  # returns badges grouped by subject_id
  def top_badges_between(period, start_date, end_date)
    Badge
      .where(type: ['Badges::TopPostBadge', 'Badges::TopPostTopicBadge'])
      .with_period(period)
      .between_dates(start_date, end_date)
      .group_by(&:subject_id)
  end
end
