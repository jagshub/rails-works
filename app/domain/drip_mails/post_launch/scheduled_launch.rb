# frozen_string_literal: true

module DripMails::PostLaunch::ScheduledLaunch
  extend self

  def call(drip_mail)
    user = drip_mail.user
    post = get_post_from_subject(drip_mail)
    return if post.nil? || !user.can_receive_email? || !user.send_onboarding_post_launch_email
    return unless scheduled_post?(post)

    DripMails::PostLaunchMailer.scheduled_launch(post, user).deliver_now
  end

  private

  def get_post_from_subject(drip_mail)
    return unless drip_mail.subject.instance_of? Post

    drip_mail.subject
  end

  def scheduled_post?(post)
    (post.scheduled_at - post.created_at).to_i / 3600 > 1
  end
end
