# frozen_string_literal: true

class MakerReportMailer < ApplicationMailer
  def digest(presenter)
    email_campaign_name "Maker Report (Week #{ Time.zone.now.strftime('%U') })"

    @presenter = presenter
    @unsubscribe_url = Notifications::UnsubscribeWithToken.url kind: :maker_report, user: presenter.user

    mail(
      to: presenter.user_email,
      subject: "#{ presenter.activity_count } updates on your product launch",
    )
  end
end
