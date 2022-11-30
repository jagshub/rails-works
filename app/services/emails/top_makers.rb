# frozen_string_literal: true

# Sends notification to the top makers of the day
class Emails::TopMakers
  attr_reader :day

  class << self
    def call(day)
      new(day).call
    end
  end

  def initialize(day)
    @day = day
  end

  def call
    top_ten_posts.each do |post|
      next unless post.maker_inside?

      Notifications.notify_about(kind: 'top_maker', object: post)
    end
  end

  private

  def top_ten_posts
    posts_for_day = Posts::Ranking.for_day(day)
    posts_for_day[0..9]
  end
end
