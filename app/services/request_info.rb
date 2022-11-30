# frozen_string_literal: true

class RequestInfo
  attr_reader :request

  def initialize(request)
    @request = request
  end

  def to_hash
    return {} if request.blank?

    {
      browser: browser_name,
      device_type: device_type,
      os: os,
      os_version: os_version,
      referer: referer,
      first_referer: first_referer,
      request_ip: request_ip,
      user_agent: user_agent,
      visit_duration: visit_duration,
      country: country,
    }
  end

  def request_ip
    return if request.blank?

    request.ip
  end

  def user_agent
    return if request.blank?

    request.user_agent
  end

  def referer
    return if request.blank?

    request.referer
  end

  def device_type
    if mobile?
      :mobile
    elsif tablet?
      :tablet
    elsif desktop?
      :desktop
    else
      :other
    end
  end

  def mobile?
    browser.device.mobile?
  end

  def tablet?
    browser.device.tablet?
  end

  def desktop?
    browser.platform.mac? || browser.platform.windows? || browser.platform.linux? || browser.platform.chrome_os? || browser.platform.firefox_os?
  end

  delegate :name, to: :browser, prefix: true
  delegate :bot?, to: :browser

  def os
    browser.platform.id
  end

  def os_version
    browser.platform.version
  end

  def first_referer
    return if request.blank?

    referer_host_and_path(request.cookies[:first_referer])
  end

  def visit_duration
    return if request.blank?

    value = request.cookies[:first_visit_at]
    Time.current.to_i - value.to_i
  end

  def country
    return if request.blank?

    request.headers.env['HTTP_CF_IPCOUNTRY']
  end

  private

  def browser
    @browser ||= ::Browser.new(user_agent)
  end

  def referer_host_and_path(value)
    return if value.blank?

    uri = Addressable::URI.parse(value)
    [uri.host, uri.path].join
  end
end
