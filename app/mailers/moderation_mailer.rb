# frozen_string_literal: true

class ModerationMailer < ApplicationMailer
  def accepted_duplicate_post_request(user:, post:, url:)
    @user = user
    @post = post
    @post_url = url

    mail(to: @user.email,
         from: CommunityContact.default_from,
         cc: CommunityContact::EMAIL,
         subject: 'Your launch request has been approved',
         reply_to: CommunityContact::REPLY,
         delivery_method_options: CommunityContact.delivery_method_options)
  end

  def rejected_duplicate_post_request(user:, post:)
    @user = user
    @post = post
    @next_launch_date = (post.date + 6.months).strftime('%d %b %Y')

    mail(to: @user.email,
         from: CommunityContact.default_from,
         cc: CommunityContact::EMAIL,
         subject: 'Your launch request has not been approved',
         reply_to: CommunityContact::REPLY,
         delivery_method_options: CommunityContact.delivery_method_options)
  end
end
