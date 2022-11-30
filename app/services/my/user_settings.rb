# frozen_string_literal: true

class My::UserSettings
  include MiniForm::Model

  model :user, attributes: %i(
    name
    headline
    about
    avatar
    website_url
    header
    header_uuid
    private_profile
    hide_hiring_badge
    job_role
    skills
    job_search
    country
    state
    city
    remote
    confirmed_age
    default_goal_session_duration
    crypto_wallet
  ) + Notifications::UserPreferences::FLAGS, save: true

  attr_reader :can_change_username

  # NOTE(rstankov): `username` is not delegated to `user`, since `change_username` expects unaltered `user.username`
  attributes :username

  # NOTE(rstankov): Don't update subscriber directly, use `Newsletter::Subscriptions`
  attributes :email, :newsletter_subscription, :jobs_newsletter_subscription, :stories_newsletter_subscription

  # NOTE(Raj): Below attributes are used for v6 grouped notification settings UI
  attributes :send_activity_browser_push, :send_activity_email
  attributes :send_community_updates_browser_push, :send_community_updates_email
  attributes :send_ph_updates_browser_push, :send_ph_updates_email
  attributes :send_maker_updates_email, :send_ship_updates_email, :unsubscribe_from_all_notifications
  attributes :links, :topic_ids

  # NOTE(rstankov): Uniqueness validation for `email` should be skipped
  validates :email, email_format: true, allow_blank: true, allow_nil: true

  validate :ensure_valid_username
  validate :ensure_valid_email
  validate :ensure_valid_website_url

  after_update :send_verification_email

  def initialize(user, source: :user_settings, onboarding: false)
    @user = user
    @username = user.username
    @subscriber = Subscriber.for_user(user)
    @email = @subscriber.email
    @newsletter_subscription = @subscriber.newsletter_subscription
    @jobs_newsletter_subscription = @subscriber.jobs_newsletter_subscription
    @stories_newsletter_subscription = @subscriber.stories_newsletter_subscription
    @tracking_options = { source: source }
    @onboarding = onboarding
    @can_change_username = ApplicationPolicy.can?(user, :change_username_user)
    @old_data = copy_data
  end

  def email=(value)
    return unless ApplicationPolicy.can?(user, :change_email, user)

    @email = EmailValidator.normalize(value)
  end

  def avatar=(value)
    Image::Uploads::Avatar.call(value, user: user, upload_key: SecureRandom.uuid) if value
  rescue Image::Upload::FormatError => e
    ErrorReporting.report_warning(e)
    nil
  end

  def crypto_wallet=(value)
    Users::CryptoWallet.create!(user: user, address: value, provider: 'ethereum') if value && user.crypto_wallet.nil?
  end

  def newsletter_subscription=(value)
    if value == 'none'
      @newsletter_subscription = false
    elsif value.present?
      @newsletter_subscription = value
    end
  end

  def jobs_newsletter_subscription=(value)
    @jobs_newsletter_subscription = value unless value.nil?
  end

  def stories_newsletter_subscription=(value)
    @stories_newsletter_subscription = value unless value.nil?
  end

  def send_activity_browser_push
    send_new_follower_browser_push || send_mention_browser_push
  end

  def send_activity_email
    send_mention_email || send_comment_digest_email || send_shoutout_mention_email || send_new_follower_email
  end

  def send_activity_browser_push=(value)
    user.send_mention_browser_push = value
    user.send_new_follower_browser_push = value
  end

  def send_activity_email=(value)
    user.send_new_follower_email = value
    user.send_mention_email = value
    user.send_comment_digest_email = value
    user.send_shoutout_mention_email = value
  end

  def send_community_updates_browser_push
    send_friend_post_browser_push
  end

  def send_community_updates_email
    send_discussion_created_email || send_collection_digest_email || send_friend_post_email || send_user_badge_award_email
  end

  def send_community_updates_browser_push=(value)
    user.send_friend_post_browser_push = value
  end

  def send_community_updates_email=(value)
    user.send_discussion_created_email = value
    user.send_collection_digest_email = value
    user.send_friend_post_email = value
    user.send_user_badge_award_email = value
  end

  def send_ph_updates_browser_push
    send_announcement_browser_push
  end

  def send_ph_updates_email
    product = Product.find_by(id: Config.ph_product_id)
    Subscribe.subscribed?(product, user) || send_golden_kitty_email || send_makers_festival_email
  end

  def send_ph_updates_browser_push=(value)
    user.send_announcement_browser_push = value
  end

  def send_ph_updates_email=(value)
    user.send_golden_kitty_email = value
    user.send_makers_festival_email = value
    update_user_product_subscription(Config.ph_product_id, value)
  end

  delegate :send_promotions_email=, to: :user

  def update_user_product_subscription(product_id, value)
    product = Product.find_by id: product_id
    return unless product

    if value
      ::Subscribe.subscribe(product, user)
    else
      ::Subscribe.unsubscribe(product, user)
    end
  end

  def send_maker_updates_email
    send_onboarding_post_launch_email || send_maker_report_email || send_maker_instructions_email || send_featured_maker_email || send_dead_link_report_email || send_awarded_badges_email
  end

  def send_maker_updates_email=(value)
    user.send_onboarding_post_launch_email = value
    user.send_maker_report_email = value
    user.send_maker_instructions_email = value
    user.send_featured_maker_email = value
    user.send_dead_link_report_email = value
    user.send_awarded_badges_email = value
  end

  def send_ship_updates_email
    send_upcoming_page_stats_email || send_stripe_discount_email || send_upcoming_page_promotion_scheduled_email
  end

  def send_ship_updates_email=(value)
    user.send_upcoming_page_stats_email = value
    user.send_stripe_discount_email = value
    user.send_upcoming_page_promotion_scheduled_email = value
  end

  def unsubscribe_from_all_notifications
    not_subscribed_to_newsletters = !subscriber.subscribed_to_newsletter? && !subscriber.subscribed_to_jobs_newsletter? && !subscriber.subscribed_to_stories_newsletter?
    !Notifications::UserPreferences.subscribed_to_any_notification?(user) && not_subscribed_to_newsletters
  end

  def unsubscribe_from_all_notifications=(value)
    Notifications::UserPreferences.unsubscribe_from_all(user) if value
    @newsletter_subscription = Newsletter::Subscriptions::UNSUBSCRIBED if value
    @jobs_newsletter_subscription = Jobs::Newsletter::Subscriptions::UNSUBSCRIBED if value
    @stories_newsletter_subscription = Anthologies::Stories::Newsletter::Subscriptions::UNSUBSCRIBED if value
  end

  def perform
    # Note(RO): passing in an empty array is a valid use case here, to delete all records
    Topics::Follow.set(topic_ids, user) unless topic_ids.nil?
    Users::LinkGroupUpdate.call(user: user, links: links.map(&:to_h)) unless links.nil?

    if email.blank?
      @subscriber.update!(
        email: nil,
        newsletter_subscription: Newsletter::Subscriptions::UNSUBSCRIBED,
        jobs_newsletter_subscription: Jobs::Newsletter::Subscriptions::UNSUBSCRIBED,
        stories_newsletter_subscription: Anthologies::Stories::Newsletter::Subscriptions::UNSUBSCRIBED,
      )
    else
      # Note(rstankov): We don't just call subscriber.save, because user might claim an existing email
      Newsletter::Subscriptions.set(
        user: user,
        email: email,
        status: @newsletter_subscription || Newsletter::Subscriptions::UNSUBSCRIBED,
        tracking_options: @tracking_options,
      )

      Jobs::Newsletter::Subscriptions.set(
        user: user,
        email: email,
        status: @jobs_newsletter_subscription || Jobs::Newsletter::Subscriptions::UNSUBSCRIBED,
      )

      Anthologies::Stories::Newsletter::Subscriptions.set(
        user: user,
        email: email,
        status: @stories_newsletter_subscription || Anthologies::Stories::Newsletter::Subscriptions::UNSUBSCRIBED,
      )
    end
  end

  private

  attr_reader :subscriber

  def ensure_valid_username
    return unless username != user.username

    if ApplicationPolicy.can?(user, :change_username, user) && SignIn.valid_username(username, existing_user: user)
      user.username = username
    elsif User.find_by_username(username).present?
      errors.add(:username, 'duplicated')
    else
      errors.add(:username, 'invalid')
    end
  end

  def ensure_valid_email
    errors.add(:email, 'blank') if email.blank? && user.email.present?
    return if email.blank?
    return unless subscriber.email != email

    errors.add(:email, 'duplicated') unless Subscriber.email_available?(email, for_user: user)
  end

  def ensure_valid_website_url
    errors.add(:website_url, 'Max length is 255 characters') if user.website_url.present? && user.website_url.length > 255
  end

  def copy_data
    {
      name: user.name,
      username: user.username,
      picture: user.image,
      headline: user.headline,
      email: user.email,
      website: user.website_url,
    }
  end

  def send_verification_email
    return unless @old_data[:email] != subscriber.reload.email
    return if @onboarding

    if subscriber.email.nil?
      Subscribers.unverify_email subscriber: subscriber
      return
    end

    Iterable::RemoveUserWorker.perform_later(email: @old_data[:email]) ## Note(Bharat): Remove user from Iterable when email is changed

    Subscribers.send_verification_email(
      subscriber: subscriber, first_time: false,
    )
  end
end
