# frozen_string_literal: true

# NOTE(rstankov): Since messages are send from makers and PH do not control their frequency/quality
#   Message emails are delivery from separate set of dedicated IPs (via separate pair of api keys)
module Ships::MailWithShipApiKeys
  def mail(to:, from:, subject:)
    super(
      to: to,
      from: from,
      subject: subject,
      delivery_method_options: Config.ship_email_delivery_options
    )
  end
end
