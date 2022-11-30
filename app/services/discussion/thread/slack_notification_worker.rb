# frozen_string_literal: true

class Discussion::Thread::SlackNotificationWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(thread)
    return unless ENV['SLACK_DISCUSSION_WEBHOOK']

    text = "<#{ Routes.discussion_url thread }|New discussion> by *#{ thread.user.name }*\n*#{ thread.title }*\n#{ thread.description }"
    body = {
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: text,
          },
          accessory: {
            type: 'image',
            image_url: Users::Avatar.url_for_user(thread.user, size: 120),
            alt_text: 'User avatar',
          },
        },
      ],
    }.to_json
    HTTParty.post(ENV['SLACK_DISCUSSION_WEBHOOK'], body: body)
  end
end
