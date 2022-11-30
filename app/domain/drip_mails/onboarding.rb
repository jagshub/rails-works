# frozen_string_literal: true

# Note (TC): This module creates a DripMail record specifically
# for our onboarding drip email pipeline. Since drip emails are all time-triggered
# we pre-create any email that can be sent and then on the day it should be sent determine
# in the logic of that notifier.
class DripMails::Onboarding
  attr_reader :user

  NOTIFICATION_SETTING = 'send_onboarding_email'
  ONBOARDING_REASON_TYPE = {
    'share_products': :maker_onboarding,
    'discover_products': :consumer_onboarding,
    'not_sure': :consumer_onboarding,
  }.freeze

  def initialize(user:)
    @user = user
  end

  def start
    drip_kind = onboarding_drip_kind
    queue_up_mailers_for(drip_kind)
  end

  def can_receive_onboarding_email?
    @user.can_receive_email? && @user.notification_preferences[NOTIFICATION_SETTING] == true
  end

  private

  def onboarding_drip_kind
    return :maker_onboarding if onboarding_drip_kind_maker?(user)

    :consumer_onboarding
  end

  def onboarding_drip_kind_maker?(user)
    user.onboarding_reasons.any? do |onboarding|
      ONBOARDING_REASON_TYPE[onboarding.reason.to_sym] == :maker_onboarding
    end
  end

  def queue_up_mailers_for(kind)
    DripMails.mailers_for(kind: kind).reduce([]) do |acc, (mailer, details)|
      HandleRaceCondition.call do
        unless DripMails::ScheduledMail.exists?(user_id: @user.id, mailer_name: mailer, drip_kind: kind, subject: @user)
          acc << DripMails::ScheduledMail.create!(
            user_id: @user.id,
            mailer_name: mailer,
            drip_kind: kind,
            send_on: calc_send_date(details[:qualified_at]),
            subject: @user,
          )
        end
      end

      acc
    end
  end

  def calc_send_date(period)
    return Time.zone.now if period.nil?

    period.from_now
  end
end
