# frozen_string_literal: true

module CookiePolicy
  extend self

  COOKIE_KEY = 'agreed_cookie_policy'

  def accept(user:, cookies:, ip:)
    CookiePolicyLog.create! ip_address: ip, user_id: user&.id

    cookies[COOKIE_KEY] = { value: Time.current.to_s, expires: 365.days.from_now }
  end

  def needed?(country_code:, cookies:)
    return false if cookies[COOKIE_KEY]
    return true if country_code.blank?

    EU_COUNTRIES.include?(country_code)
  end

  EU_COUNTRIES = %w(
    BE
    BG
    CZ
    DK
    DE
    EE
    IE
    EL
    ES
    FR
    HR
    IT
    CY
    LV
    LT
    LU
    HU
    MT
    NL
    AT
    PL
    PT
    RO
    SI
    SK
    FI
    SE
    UK
  ).freeze
end
