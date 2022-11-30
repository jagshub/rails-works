# frozen_string_literal: true

class Notifications::UnsubscribeWithToken
  InvalidToken = Class.new(RuntimeError)

  MAPPING = {
    'maker_digest' => -> { unsubscribe_from_maker_digest },
    'comment_notifications' => -> { unsubscribe_from_notification_setting(:send_mention_email) },
    'shoutout_mention_notification' => -> { unsubscribe_from_notification_setting(:send_shoutout_mention_email) },
    'maker_report' => -> { unsubscribe_from_notification_setting(:send_maker_report_email) },
    'product_request_notifications' => -> { unsubscribe_from_notification_setting(:send_product_request_email) },
    'friend_post_notifications' => -> { unsubscribe_from_notification_setting(:send_friend_post_email) },
    'user_badge_award_email' => -> { unsubscribe_from_notification_setting(:send_user_badge_award_email) },
    'new_follower_notifications' => -> { unsubscribe_from_notification_setting(:send_new_follower_email) },
    'collection_digest' => -> { user? ? find_user.update!(send_collection_digest_email: false) : CollectionSubscription.unsubscribe_all(email: find_email) },
    'unfollow_user' => -> { Following.unfollow(user: find_user, unfollows: User.visible.find_by(id: params[:friend_id])) },
    'daily_newsletter' => -> { change_newsletter_subscription(Newsletter::Subscriptions::WEEKLY, source: :newsletter_link) },
    'newsletter' => -> { change_newsletter_subscription(Newsletter::Subscriptions::UNSUBSCRIBED, source: :unsubscribe_link) },
    'jobs_newsletter' => -> { change_job_newsletter_subscription(Jobs::Newsletter::Subscriptions::UNSUBSCRIBED) },
    'discussion_created' => -> { unsubscribe_from_notification_setting(:send_discussion_created_email) },
    'comment_digest' => -> { unsubscribe_from_notification_setting(:send_comment_digest_email) },
    'golden_kitty_notifications' => -> { unsubscribe_from_subscription },
    'send_onboarding_email' => -> { unsubscribe_from_notification_setting(:send_onboarding_email) },
    'product_updates' => -> { unsubscribe_from_notification_setting(:send_product_updates_email) },
    'ship' => -> { unsubscribe_from_ship },
    ## Note(Bharat): the below kinds are being used in iterable.
    'maker_updates' => -> { disable_setting(:send_maker_updates_email) }, # Note(Bharat): this is for backward compatibility. changing every kind to have ph as prefix.
    'ph_maker_updates' => -> { disable_setting(:send_maker_updates_email) },
    'ph_updates' => -> { disable_setting(:send_ph_updates_email) },
    'ph_community' => -> { disable_setting(:send_community_updates_email) },
    'ph_activities' => -> { disable_setting(:send_activity_email) },
    'ph_ship' => -> { disable_setting(:send_ship_updates_email) },
    'ph_jobs_digest' => -> { disable_setting(:jobs_newsletter_subscription) },
    'ph_recommendations' => -> { disable_setting(:send_ph_recommendations_email) },
    'ph_recommendations_email' => -> { disable_setting(:send_ph_recommendations_email) }, # Note(Bharat): this is for backward compatibility
    'promotions' => -> { disable_setting(:send_promotions_email) },
    'ad_notifications' => -> { disable_setting(:send_promotions_email) }, # Note(Bharat): this is for backward compatibility
  }.freeze

  MESSAGES = {
    'comment_notifications' => "You're now unsubscribed from comment emails.",
    'shoutout_mention_notification' => "You're now unsubscribed from Shout-out mention emails.",
    'friend_post_notifications' => "You're now unsubscribed from post emails.",
    'product_request_notifications' => "You're now unsubscribed from product request emails.",
    'new_follower_notifications' => "You're now unsubscribed from new follower emails.",
    'collection_digest' => "You're now unsubscribed from collection update emails.",
    'daily_newsletter' => "You'll now receive our weekly newsletter.",
    'newsletter' => 'You’re now unsubscribed from The Product Hunt Daily.',
    'jobs_newsletter' => "You're now unsubscribed from jobs newsletter emails.",
    'discussion_created' => "You're now unsubscribed from new discussion emails.",
    default: "You're now unsubscribed from these kinds of emails.",
  }.freeze

  class << self
    def call(params:)
      return { status: 'failure' } if !params.key?(:kind) || params[:kind].blank?

      new(params: params).call

      { status: 'success', message: MESSAGES[params[:kind]] || MESSAGES[:default] }
    rescue InvalidToken
      { status: 'failure' }
    end

    def params(kind:, user: nil, email: nil, **others)
      raise "Invalid kind - #{ kind }" unless valid_kind?(kind)
      raise 'Provide user or email' unless user.present? || email.present?

      others.merge(EmailUnsubscribeToken.encode_for(user: user, email: email)).merge(kind: kind)
    end

    def url(kind:, user: nil, email: nil, **others)
      url_params = params(kind: kind, user: user, email: email, **others)
      Routes.my_unsubscribe_url(url_params)
    end

    def valid_kind?(kind)
      MAPPING.key? kind.to_s
    end
  end

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def call
    kind = params[:kind]

    raise "Invalid kind - #{ kind }" unless MAPPING.key? kind

    handler = MAPPING[kind]

    instance_exec(&handler)
  end

  def user?
    params[:user_id].present?
  end

  def find_email
    raise InvalidToken unless valid_token? :email

    params[:email].downcase
  end

  # Note(Mike Coutermarsh): We do not check `current_user` here because users will often be signed up
  #   under multiple accounts. Logged in with 1, but trying to unsub from another. No matter what account
  #   they are logged in as, we want them to be able to unsubscribe.
  def find_user
    raise InvalidToken unless valid_token? :user_id

    user = User.visible.find_by(id: params[:user_id])

    raise InvalidToken if user.blank?

    user
  end

  def valid_token?(identifier)
    return false if params[:token].blank?
    return false if params[identifier].blank?

    if params[:valid_until].present? ## For permanent tokens, valid_until is not present
      return false unless EmailUnsubscribeToken.valid?(identifier: params[identifier], valid_until: params[:valid_until], token: params[:token])
    else
      return false unless EmailUnsubscribeToken.permanent_token_valid?(identifier: params[identifier], token: params[:token])
    end

    true
  end

  private

  def change_newsletter_subscription(new_status, source:)
    tracking_options = { source: source, notification: find_notification }
    Newsletter::Subscriptions.set(email: find_email, status: new_status, tracking_options: tracking_options)
  end

  def change_job_newsletter_subscription(new_status)
    Jobs::Newsletter::Subscriptions.set(email: find_email, status: new_status)
  end

  def unsubscribe_from_notification_setting(setting)
    find_user.update!(setting => false)

    NotificationUnsubscriptionLog.create_from_notification!(find_notification, source: :unsubscribe_link) if find_notification.present?
  end

  def unsubscribe_from_maker_digest
    subscriber = find_user.subscriber
    subscriber.update! maker_digest_subscription: false
  end

  def disable_setting(setting)
    user = find_user
    form = My::UserSettings.new(user)
    form.update!(setting => false)
    Iterable::SyncUserSubscriptionWorker.perform_later(user) ## Note(Bharat): sync user subscriptions with iterable
  end

  def find_notification
    return if params[:ph_notification_id].blank?

    notification = NotificationEvent.find_by(id: params[:ph_notification_id])

    return if notification.blank?

    if user?
      return unless notification_belongs_to_user?(notification)
    else
      return unless notification_belongs_to_email?(notification)
    end

    notification
  end

  def find_subscription
    id = params[:subscription_id]
    return if id.blank?

    subscription = Subscription.find_by id: id
    email = find_email

    return if email != subscription.subscriber&.email

    subscription
  end

  def notification_belongs_to_user?(notification)
    notification.subscriber.user == find_user
  end

  def notification_belongs_to_email?(notification)
    subscriber = notification.subscriber
    subscriber.email&.casecmp(find_email.downcase)&.zero?
  end

  def unsubscribe_from_subscription
    subscription = find_subscription

    return if subscription.blank?

    subscription.unsubscribed!
  end

  def unsubscribe_from_ship
    user = find_user

    user.update!(
      send_upcoming_page_stats_email: false,
      send_stripe_discount_email: false,
      send_upcoming_page_promotion_scheduled_email: false,
    )
  end
end
