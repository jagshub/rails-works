# frozen_string_literal: true

require 'openssl'

module External::Intercom
  extend self

  # NOTE(RAJ): Used by Intercom's identity verification for web.
  #            Documentation: https://app.intercom.com/a/apps/fe4ce68d4a8352909f553b276994db414d33a55c/settings/identity-verification/web
  def user_hash(current_user)
    OpenSSL::HMAC.hexdigest(
      'sha256',
      Config.secret(:intercom_identity_secret),
      current_user.id.to_s,
    )
  end
end
