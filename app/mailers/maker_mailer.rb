# frozen_string_literal: true

class MakerMailer < ApplicationMailer
  before_action :disable_email_tracking, only: %i(created_first_goal)

  FROM = CommunityContact.from(name: 'Makers', email: CommunityContact::PH_EMAIL)

  def featured_in_newsletter(user, post_hash, newsletter)
    @user = user
    @post_hash = post_hash
    @newsletter = newsletter

    transactional_mail(
      subject: 'Your product is featured in the Product Hunt newsletter!',
      to: @user.email,
    )
  end

  private

  TRANSACTIONAL_MAIL_OPTS = {
    delivery_method_options: CommunityContact.delivery_method_options,
    from: CommunityContact.from(name: 'Makers', email: CommunityContact::EMAIL),
    reply_to: CommunityContact::REPLY,
  }.freeze

  def transactional_mail(opts)
    mail TRANSACTIONAL_MAIL_OPTS.merge(opts)
  end
end
