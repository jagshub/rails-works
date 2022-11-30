# frozen_string_literal: true

module Subscribe
  extend self

  def subscribe(subject, user, subscriber = nil, source: 'follow')
    HandleRaceCondition.call do
      subscription = Subscription.find_or_create_by!(subject: subject, subscriber: subscriber || user.subscriber)
      subscription.update! state: :subscribed, muted: false, source: source if source

      after_subscribe(subscription, user)

      subscription
    end
  end

  def unsubscribe(subject, user)
    subscription = subject.all_subscriptions.find_by(subscriber: user.subscriber)

    if subscription&.subscribed?
      subscription.source = nil
      subscription.unsubscribed!

      after_unsubscribe(subscription)
    end

    subscription
  end

  def mute(subject, user)
    HandleRaceCondition.call do
      subscription = Subscription.find_by(
        subject: subject,
        subscriber: user.subscriber,
      )

      subscription&.update!(muted: true)
      subscription
    end
  end

  def unmute(subject, user)
    HandleRaceCondition.call do
      subscription = Subscription.find_by(
        subject: subject,
        subscriber: user.subscriber,
      )

      subscription&.update!(muted: false)
      subscription
    end
  end

  def subscribed?(subject, user)
    subject&.subscriptions&.exists?(subscriber: user.subscriber)
  end

  # NOTE(rstankov): We don't allow auto-follow when users are already subscribed or unsubscribed.
  def auto_subscribe?(subject, user)
    Subscription.exists?(subject: subject, subscriber: user.subscriber)
  end

  def subscribeable?(subject)
    subject.is_a?(Subscribeable)
  end

  private

  def after_subscribe(subscription, user)
    case subscription.subject_type
    when 'GoldenKitty::Edition' then GoldenKitty.send_notification_confirmation(subscription)
    # Note(vlad): We need to update the frontend with a relevant number of followers
    when 'Topic' then subscription.subject.increment!(:followers_count)
    when 'Product' then
      if subscription.subject_id == Config.ph_product_id && subscription.subscriber.user
        External::MailjetApi::ContactSyncWorker.perform_later(subscription.subscriber.user)
      end
    when 'Upcoming::Event'
      ::Subscribe.subscribe(subscription.subject.product, user)
    end
  end

  def after_unsubscribe(subscription)
    case subscription.subject_type
    # Note(vlad): We need to update the frontend with a relevant number of followers
    when 'Topic' then subscription.subject.decrement!(:followers_count) if subscription.subject.followers_count > 0
    when 'Product' then
      if subscription.subject_id == Config.ph_product_id && subscription.subscriber.user
        External::MailjetApi::ContactSyncWorker.perform_later(subscription.subscriber.user)
      end
    end
  end
end
