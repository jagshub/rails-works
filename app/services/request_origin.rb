# frozen_string_literal: true

module RequestOrigin
  extend self

  ALLOWED_HOST = ['producthunt.com', 'ph.test', 'api.producthunt.com', 'ambassador.producthunt.com', 'appleid.apple.com'].freeze

  def same_origin?(request)
    return true if allowed_host? request.headers['origin']
    return true if allowed_host? request.referer
    # Note(Rahul): Host format is hostname:port so we are adding scheme to it
    return true if allowed_host? "https://#{ request.host }"

    false
  end

  def allowed_host?(url)
    url.present? && ALLOWED_HOST.include?(URI.parse(url).host&.sub('www.', ''))
  end
end
