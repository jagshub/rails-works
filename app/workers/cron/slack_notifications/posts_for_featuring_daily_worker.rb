# frozen_string_literal: true

class Cron::SlackNotifications::PostsForFeaturingDailyWorker < ApplicationJob
  def perform
    posts = Post.on_date(Date.tomorrow)

    SlackNotify.call(
      channel: :featured_posts,
      text: 'These are the posts ready for featuring for tomorrow',
      deliver_now: true,
    )

    posts.each do |post|
      SlackNotify.call(
        channel: :featured_posts,
        text: post.name,
        blocks: [
          {
            "type": 'section',
            "block_id": 'section567',
            "text": {
              "type": 'mrkdwn',
              "text": "<#{ Routes.admin_post_url(post) }|#{ post.name }> \n Tagline: #{ post.tagline } \n Featured at: #{ post.featured_at }",
            },
            "accessory": {
              "type": 'image',
              "image_url": post.thumbnail_url,
              "alt_text": post.name,
            },
          },
        ],
        deliver_now: true,
      )
    end
  end
end
