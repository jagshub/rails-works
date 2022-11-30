# frozen_string_literal: true

class DripMails::UserRetention
  attr_reader :user
  DRIP_KIND = :user_retention
  INACTIVTIY_PERIOD = 21.days
  NOTIFICATION_SETTING = 'send_onboarding_email'

  def initialize(user:)
    @user = user
  end

  def start
    new_drip_mails = DripMails.mailers_for(kind: DRIP_KIND).map do |mailer, details|
      {
        user_id: @user.id,
        mailer_name: mailer,
        drip_kind: 'user-retention',
        send_on: calc_send_date(details[:qualified_at]),
        subject: @user,
      }
    end

    DripMails::ScheduledMail.create!(new_drip_mails)
  end

  def can_receive_user_retention_email?
    @user.can_receive_email? && @user.notification_preferences[NOTIFICATION_SETTING] == true
  end

  private

  def calc_send_date(period)
    return Time.zone.now if period.nil?

    Time.zone.now + period
  end
end
