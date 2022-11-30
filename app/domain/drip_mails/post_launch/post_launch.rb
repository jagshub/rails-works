# frozen_string_literal: true

module DripMails::PostLaunch::PostLaunch
  extend self

  def call(drip_mail)
    user = drip_mail.user
    post = get_post_from_subject(drip_mail)
    return if post.nil? || post.trashed? || !post.featured?
    return if !user.can_receive_email? || !user.send_onboarding_post_launch_email

    DripMails::PostLaunchMailer.post_launch(post, user).deliver_now
  end

  private

  def get_post_from_subject(drip_mail)
    return unless drip_mail.subject.instance_of? Post

    drip_mail.subject
  end
end
