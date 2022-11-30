# frozen_string_literal: true

module Discussion::PendingSlackNotifier
  extend self

  def send_notification(discussion)
    return unless Rails.env.production?

    SlackNotify.call(
      channel: 'pending_discussions',
      text: discussion.title,
      blocks: [
        {
          "type": 'section',
          "block_id": 'section567',
          "text": {
            "type": 'mrkdwn',
            "text": "<#{ Routes.admin_discussion_thread_url(discussion) }|#{ discussion.title }> \n Description: #{ discussion.description || 'No description' }",
          },
        },
      ],
    )
  end
end
