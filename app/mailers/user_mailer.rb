# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def maker_instructions(user, post)
    # Before sending, ensure they are still a maker of this post.
    return if ProductMaker.find_by(user: user, post: post).blank?

    @user = user
    @post = post

    email_campaign_name 'maker_instructions'

    mail(to: @user.email,
         from: CommunityContact.default_from,
         cc: CommunityContact::EMAIL,
         subject: "#{ @post.name } is featured on Product Hunt 😸",
         reply_to: CommunityContact::REPLY,
         delivery_method_options: CommunityContact.delivery_method_options)
  end

  def email_verification(subscriber, skip_tracking: false)
    @user = subscriber.user
    @subscriber = subscriber
    @skip_tracking = skip_tracking
    @confirm_url = Routes.my_confirm_email_url(token: @subscriber.verification_token)

    build_mail 'Confirm your Product Hunt account ✅'
  end

  def email_updated_verification(subscriber, skip_tracking: false)
    @user = subscriber.user
    @subscriber = subscriber
    @skip_tracking = skip_tracking
    @confirm_url = Routes.my_confirm_email_url(token: @subscriber.verification_token)

    build_mail 'Confirm your new email'
  end

  def new_social_login_requested(new_social_login, skip_tracking: false)
    @user = new_social_login.user
    @method = new_social_login.social
    @skip_tracking = skip_tracking
    @login_url = Routes.auth_new_social_login_authenticate_url(
      token: new_social_login.token,
    )

    build_mail 'New social login detected'
  end

  def welcome(user)
    disable_email_tracking

    @user = user

    build_mail "Welcome to Product Hunt, #{ user.name }! 👋"
  end

  def account_suspended(user)
    @user = user

    build_mail 'Important information regarding your Product Hunt profile'
  end

  def company_account(user)
    @user = user
    return unless user.company?

    build_mail 'Please update your account to post and comment on Product Hunt'
  end

  def badge_awarded(user, badge)
    return if user&.email.blank?
    return unless user&.send_user_badge_award_email?

    email_campaign_name 'User Badge Awarded'
    @user = user
    @badge = badge
    @tracking_params = Metrics.url_tracking_params(
      medium: :email, object: 'user_badge_awarded',
    )
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(
      kind: :user_badge_award_email, user: user,
    )

    build_mail 'You have been awarded a badge!'
  end

  private

  def build_mail(subject)
    mail(
      to: @user.email,
      from: CommunityContact.from,
      subject: subject,
      reply_to: CommunityContact::EMAIL,
      delivery_method_options: CommunityContact.delivery_method_options,
    )
  end
end
