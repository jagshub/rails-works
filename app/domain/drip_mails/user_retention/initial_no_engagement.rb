# frozen_string_literal: true

module DripMails::UserRetention::InitialNoEngagement
  extend self

  def call(drip_mail)
    user = drip_mail.user
    return unless DripMails::UserRetention.new(user: user).can_receive_user_retention_email?

    DripMails::UserRetentionMailer.initial_no_engagement(user).deliver_now
  end
end
