# frozen_string_literal: true

class Posts::NotifyAboutPostSubmissionWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(post)
    title = title_for(post)

    SlackNotify.call(
      channel: :post_activity,
      username: post.user.username,
      icon_emoji: ':calendar:',
      attachment:
      {
        author_name: post.user.name,
        author_link: Routes.profile_url(post.user),
        author_icon: Users::Avatar.url_for_user(post.user),
        fallback: title,
        color: '#66be00',
        title: title,
        title_link: Routes.post_url(post),
        fields: fields_for(post),
      },
    )
  end

  private

  def title_for(post)
    case post.state
    when :trashed
      "Trashed post: #{ post.name }"
    when :scheduled
      if post.featured_at?
        "Scheduled feature by user post: #{ post.name }"
      else
        "Scheduled by user post: #{ post.name }"
      end
    when :not_featured
      "Not featured post: #{ post.name }"
    when :featured
      "Featured by user post: #{ post.name }"
    else
      "Uknown state of post: #{ post.name }"
    end
  end

  def fields_for(post)
    fields = [
      { title: 'Name', value: post.name, short: true },
      { title: 'Tagline', value: post.tagline, short: true },
    ]

    fields << { title: 'Featured at', value: post.featured_at.to_s(:long_ordinal), short: true } if post.featured_at&.present?
    fields << { title: 'Scheduled at', value: post.scheduled_at.to_s(:long_ordinal), short: true } if post.scheduled_at&.future?
    fields << { title: 'Trashed at', value: post.trashed_at.to_s(:long_ordinal), short: true } if post.trashed_at&.future?

    fields
  end
end
