# frozen_string_literal: true

class DiscussionsMailer < ApplicationMailer
  def approval(discussion, user)
    @discussion = discussion
    @user = user

    mail(
      to: user.email,
      subject: "Your Discussion: #{ discussion.title } has been approved",
    )
  end

  def digest(user, notifications)
    email_campaign_name 'discussions_digest'

    @unsubscribe_url = Notifications::UnsubscribeWithToken.url kind: :comment_digest, user: user
    @digest_content = DiscussionsDigest.comment_threads_from(notifications)
    @user = user

    return if @digest_content.map(&:comments_count).reject(&:zero?).empty?

    mail(
      to: @user.email,
      subject: 'Discussions Digest',
    )
  end

  def new_discussion(thread, user)
    email_campaign_name 'New Maker Discussion'

    @thread = thread
    @user = user
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url kind: :discussion_created, user: user
    @unfollow_url = Notifications::UnsubscribeWithToken.url(kind: 'unfollow_user', user: user, friend_id: @thread.user.id)
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'new_friend_discussion')

    mail(
      subject: "#{ @thread.user.name } started a discussion!",
      to: @user.email,
    )
  end
end
