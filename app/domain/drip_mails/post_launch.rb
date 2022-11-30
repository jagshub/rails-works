# frozen_string_literal: true

class DripMails::PostLaunch
  attr_reader :post
  DRIP_KIND = :post_launch

  def initialize(post:)
    @post = post
  end

  def start
    new_drip_mails = DripMails.mailers_for(kind: DRIP_KIND).map do |mailer, details|
      {
        user_id: @post.user_id,
        mailer_name: mailer,
        drip_kind: 'post-launch',
        send_on: calc_send_date(details[:qualified_at]),
        subject: @post,
      }
    end

    DripMails::ScheduledMail.create!(new_drip_mails)
  end

  private

  def calc_send_date(period)
    return Time.zone.now if period.nil?

    post.scheduled_at + period
  end
end
