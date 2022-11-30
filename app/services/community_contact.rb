# frozen_string_literal: true

module CommunityContact
  extend self

  # NOTE(rstankov): Uses transactional Mailjet account key
  NAME = 'Jake Crump'
  EMAIL = 'hello@team.producthunt.com'

  NEWSLETTER_CONTACT_NAME = 'Sarah Wright'
  NEWSLETTER_CONTACT_EMAIL = 'sarah@team.producthunt.com'
  NEWSLETTER_CONTACT_REPLY = 'sarah@producthunt.com'

  PROGRAMS_MANAGER = 'Sharath'

  # NOTE(rstankov): Uses default Mailjet account key
  PH_NAME = 'Product Hunt'
  PH_EMAIL = 'hello@producthunt.com'

  FOUNDER_CLUB_CONTACT = 'lanre@producthunt.com'
  JOBS_CONTACT = 'emily@producthunt.com'

  REPLY = 'hello@producthunt.com'

  PREMIUM_SHIP = 'sos@producthunt.com'
  PAYMENTS = 'sos@producthunt.com'

  DEV_EMAIL = 'dev@producthunt.co'

  def from(name: NAME, email: EMAIL)
    "#{ name } <#{ email }>"
  end

  def default_from
    from(name: PH_NAME, email: EMAIL)
  end

  def delivery_method_options
    api_key = ENV.fetch('MAILJET_TRANSACTIONAL_PUBLIC_KEY')
    secret_key = ENV.fetch('MAILJET_TRANSACTIONAL_PRIVATE_KEY')

    raise 'Missing MAILJET_TRANSACTIONAL_* keys' if api_key.nil? || secret_key.nil?

    {
      api_key: api_key,
      secret_key: secret_key,
    }
  end
end
