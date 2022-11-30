# frozen_string_literal: true

class Admin::UserForm
  include MiniForm::Model

  model :user, save: true, read: %i(id persisted? header_url), attributes: (%i(
    beta_tester
    header
    headline
    about
    image
    login_count
    name
    permissions
    private_profile
    role
    twitter_username
    twitter_verified
    username
    verified
    website_url
    role_reason
    ambassador
    login_count
  ) + Notifications::UserPreferences::FLAGS + SignIn::SOCIAL_ATTRIBUTES)

  model :subscriber, save: true, attributes: %i(
    email
    email_confirmed
    newsletter_subscription
  )

  validate :ensure_unique_social_attributes

  def initialize(user)
    @user = user
    @subscriber = Subscriber.for_user(user)
  end

  def ensure_unique_social_attributes
    SignIn::SOCIAL_ATTRIBUTES.each do |social_attribute|
      next if user[social_attribute].blank?

      other_user = User.where.not(id: user.id).find_by(social_attribute => user[social_attribute])

      if other_user.present?
        errors.add social_attribute, "This #{ social_attribute } is taken by @#{ other_user.username }"
      end
    end
  end

  private

  def before_update
    send_company_alert_email if user.role_changed? && user.company?
  end

  def send_company_alert_email
    UserMailer.company_account(user).deliver_later
  end
end
