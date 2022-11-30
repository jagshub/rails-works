# frozen_string_literal: true

module SlackBot
  extend self

  def greet(user)
    return if user.blank?
    return if user.subscriber.blank?

    SlackBot::GreetingWorker.perform_later user.subscriber
  end

  def activate(user, code)
    return false if code.blank?

    response = oauth_access(code)

    return false unless response['ok']

    subscriber = Subscriber.for_user(user)
    subscriber.update!(
      slack_active: true,
      slack_access_token: response['access_token'],
      slack_scope: response['scope'],
      slack_user_id: response['user_id'],
      slack_team_name: response['team_name'],
      slack_team_id: response['team_id'],
      slack_webhook_channel: response['incoming_webhook']['channel'],
      slack_webhook_channe_id: response['incoming_webhook']['channel_id'],
      slack_webhook_configuration_url: response['incoming_webhook']['configuration_url'],
      slack_webhook_url: response['incoming_webhook']['url'],
    )

    ::SlackBot::AfterActivationWorker.perform_later(user)

    true
  end

  def active_for?(user)
    return false unless user&.subscriber

    user.subscriber.slack_active
  end

  def deactivate(user)
    return unless user.subscriber

    user.subscriber.update! slack_active: false
  end

  private

  def oauth_access(code)
    # NOTE(rstankov): Documentation:
    # https://api.slack.com/methods/oauth.access
    query = {
      client_id: ENV['SLACK_CLIENT_ID'],
      client_secret: ENV['SLACK_CLIENT_SECRET'],
      code: code,
    }
    HTTParty.get "https://slack.com/api/oauth.access?#{ query.to_query }"
  rescue HTTParty::Error
    {}
  end
end
