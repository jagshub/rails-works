# frozen_string_literal: true

module HouseKeeper::Maintain
  extend self

  class ResponseMisaligned < StandardError; end

  GRACE_PERIOD = 3.months
  NOTIFICATION_PERIOD = 24.months
  HTTPARTY_OPTIONS = {
    # NOTE(DZ): httparty with limit = 1 is the same as no_follow. We want 3
    # redirects as maximum
    limit: 4,
    follow_redirects: true,
    timeout: 30,
    headers: {
      # NOTE(DZ): Some websites uses unsupport compression methods. (Zlib::DataError)
      'accept-encoding' => 'none',
      # NOTE(DZ): Some websites require user agent to be present (i.e. amazon)
      'User-Agent' => 'HTTParty',
    },
  }.freeze

  REQUEST_ERRORS =
    ActiveJobHandleNetworkErrors::HTTP_ERRORS + [
      HTTParty::RedirectionTooDeep,
      Errno::EADDRNOTAVAIL,
      Errno::EHOSTUNREACH,
      URI::InvalidURIError,
    ]

  def batch(product_links)
    product_links.each do |product_link|
      call(product_link, dry_run: true)
    end
  end

  def call(product_link, dry_run: false)
    status, error = verify(product_link)

    if !status && !dry_run
      mark_link_as_broken(product_link, error)
      mark_post_as_broken(product_link)
    end

    status
  end

  private

  def verify(product_link)
    response = HTTParty.get(product_link.url, HTTPARTY_OPTIONS)

    # NOTE(DZ): For right now, do not attempt to check if store links are
    # available. Would create too many false positives
    [response.code < 300, response.code]
  rescue *REQUEST_ERRORS => e
    [false, "#{ e.class }, #{ e }"]
  rescue NoMethodError => e
    # NOTE(DZ): A NoMethodError can happen within HTTParty. Mark these without
    # interrupting jobs here.
    ErrorReporting.report_warning(e, extra: { product_link: product_link.id })
    [false, "#{ e.class }, #{ e }"]
  end

  def mark_link_as_broken(product_link, status)
    return if product_link.post.created_at > GRACE_PERIOD.ago

    has_previous_failures =
      HouseKeeperBrokenLink.previous_month_failure(product_link).any?

    HouseKeeperBrokenLink.create!(
      product_link: product_link,
      reason: status.to_s,
    )

    product_link.update!(broken: true) if has_previous_failures
  end

  def mark_post_as_broken(product_link)
    post = product_link.post

    return if post.no_longer_online? || post.links.not_broken.any?

    post.no_longer_online!
    post.update!(locked: false)

    return if post.created_at <= NOTIFICATION_PERIOD.ago

    post.makers.each do |maker|
      next unless maker.send_dead_link_report_email

      HouseKeeperMailer.dead_link(post, maker).deliver_later
    end
  end
end
