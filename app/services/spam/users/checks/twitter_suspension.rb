# frozen_string_literal: true

module Spam::Users::Checks::TwitterSuspension
  extend self

  CHECK_NAME = 'Check: Twitter Account Suspension'
  ACTIONS = %w(update_role mark_votes).freeze

  def perform_all_later(active_at: nil, batch_size: 100)
    users = User.where(role: :user).where.not(twitter_uid: nil)
    users = users.where('last_active_at >= ?', active_at) if active_at.present?

    users.find_in_batches(batch_size: batch_size) { |users_batch| Spam::TwitterSuspensionCheckWorker.perform_later(users: users_batch) }
  end

  def run(users:)
    valid_twitter_uids = get_valid_twitter_uids(users)
    spam_users = users.reject { |user| valid_twitter_uids.include? user.twitter_uid.to_i }

    spam_users.each do |user|
      spam_log = Spam.log_entity(
        entity: user,
        user: user,
        kind: :automatic,
        action: :mark_as_spam,
        level: :inappropriate,
        current_user: CHECK_NAME,
        remarks: 'Twitter account for the user has been suspended.',
      )

      Spam::SpamUserWorker.perform_later(
        {
          user: user,
          kind: 'automatic',
          level: 'inappropriate',
          parent_log_id: spam_log.id,
          current_user: CHECK_NAME,
        },
        actions: ACTIONS,
      )
    end
  end

  def check_false_positives(logged_after:)
    spam_logs = Spam::Log
                .where('created_at >= ? AND parent_log_id IS NULL', logged_after)
                .by_check(:twitter_suspension)
                .preload(:user)
    valid_twitter_uids = get_valid_twitter_uids(spam_logs.map(&:user))

    undo_false_positives(spam_logs.select { |log| valid_twitter_uids.include? log.user_id }).map(&:user)
  end

  private

  def get_valid_twitter_uids(users)
    raise 'Max 100 users allowed at a time.' if users.length > 100

    client = Twitter::REST::Client.new do |c|
      c.consumer_key        = ENV['TWITTER_SPAM_KEY']
      c.consumer_secret     = ENV['TWITTER_SPAM_SECRET']
    end

    begin
      client.users(users.map { |user| user.twitter_uid.to_i }).map &:id
    rescue Twitter::Error::NotFound
      []
    end
  end

  def undo_false_positives(false_positives)
    false_positives.each do |log|
      ActiveRecord::Base.transaction do
        false_positive_log = Spam.log_entity(
          user: log.user,
          entity: log.user,
          action: :unmark_as_spam,
          kind: :automatic,
          level: :inappropriate,
          remarks: 'Twitter account for the user has been found to be active again after suspension earlier.',
          parent_log_id: log.id,
          current_user: CHECK_NAME,
        )

        log.user.update!(role: :user)

        Spam::Log.where(user: log.user, content_type: :vote, action: :mark_as_non_credible).by_check(:twitter_suspension).find_each do |vote_log|
          vote_log.update!(false_positive: true)

          vote = Vote.where(id: vote_log.content).first
          break if vote.nil?

          Spam.log_entity(
            user: vote.user,
            entity: vote,
            action: :mark_as_credible,
            kind: :automatic,
            level: :inappropriate,
            remarks: 'Check parent log for more info.',
            parent_log_id: false_positive_log.id,
            current_user: CHECK_NAME,
          )

          vote.update!(credible: true, sandboxed: false)
        end

        log.update!(false_positive: true)
      end
    end

    false_positives
  end
end
