# frozen_string_literal: true

module SlackBot::Greeting
  extend self

  def deliver_for(subscriber)
    return unless subscriber.slack_active

    Notifications::Channels::Slack::Service.call(
      url: subscriber.slack_webhook_url,
      message: { text: message_for(subscriber) },
    )
  end

  def message_for(subscriber)
    upcoming_pages = upcoming_pages_text subscriber.user

    "hi, new friends! I’m here to keep up-to-date#{ upcoming_pages } starting meow. Thanks so much for inviting me! :raised_hands:"
  end

  private

  def upcoming_pages_text(user)
    return '' if user.nil?

    upcoming_pages = UpcomingPage.for_maintainers(user).to_a

    return '' if upcoming_pages.empty?

    " on #{ upcoming_pages.map { |page| "`#{ page.name }`" }.join ', ' }"
  end
end
