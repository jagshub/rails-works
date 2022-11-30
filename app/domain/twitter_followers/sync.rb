# frozen_string_literal: true

class TwitterFollowers::Sync < ApplicationJob
  include ActiveJobHandleNetworkErrors
  queue_as :default

  def perform(subject:)
    return unless TwitterFollowerCount::SUBJECTS.include?(subject.class)

    username = subject_twitter_username(subject)
    return if username.nil?

    follower_count = fetch_follower_count(username)
    return if follower_count.nil?

    HandleRaceCondition.call do
      TwitterFollowerCount.find_or_initialize_by(subject: subject).update!(follower_count: follower_count, last_checked: Time.zone.now)
    end
  end

  private

  def subject_twitter_username(subject)
    if subject.respond_to? :twitter_username # Note(TC): Will cover both User and Product
      subject.twitter_username
    elsif subject.respond_to? :twitter_url # Note(TC): Will cover Product
      return if subject.twitter_url.nil?

      subject.twitter_url.split('twitter.com/')[1]
    end
  end

  def fetch_follower_count(username)
    client = Twitter::REST::Client.new do |c|
      c.consumer_key        = ENV['TWITTER_SPAM_KEY']
      c.consumer_secret     = ENV['TWITTER_SPAM_SECRET']
    end

    begin
      client.user(username).followers_count
    rescue Twitter::Error::NotFound
      nil # Note(TC): If a username given to us was not valid, we dont want to continue to track it and consume API calls
    rescue Twitter::Error::ClientError, Twitter::Error::Forbidden, Twitter::Error::ServerError
      0
    end
  end
end
