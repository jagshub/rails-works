# frozen_string_literal: true

module TrackingPixel
  extend self

  SKIPPED_HOSTS = %w(producthunt.com api.producthunt.com www.producthunt.com localhost 127.0.0.1 ph.test).freeze

  def track(embeddable, kind, url)
    host = get_host(url)

    return if host.blank?
    return unless allowed_host?(host)

    HandleRaceCondition.call do
      log = TrackingPixel::Log.find_by(
        kind: kind,
        host: host,
        embeddable: embeddable,
      )

      if log.present?
        log.update url: url, last_seen_at: Time.zone.now unless log.url == url && log.last_seen_at > 1.day.ago

        return log
      end

      log = TrackingPixel::Log.create!(
        kind: kind,
        embeddable: embeddable,
        host: host,
        url: url,
        last_seen_at: Time.zone.now,
      )

      yield if block_given?

      log
    end
  end

  def tracked?(embeddable, kind)
    scope = TrackingPixel::Log.by_fresh.where(kind: kind, embeddable: embeddable)

    if post? embeddable
      host = allowed_post_host(embeddable)
      scope = scope.where(host: host) if host.present?
    end

    scope.any?
  end

  private

  def get_host(url)
    return if url.blank?

    host = nil
    begin
      host = Addressable::URI.parse(url).host
    rescue StandardError => e
      ErrorReporting.report_warning(e)
    end

    host
  end

  def post?(embeddable)
    embeddable.class.name == 'Post'
  end

  def allowed_post_host(post)
    return if post.primary_link.store.present?

    Addressable::URI.parse(post.primary_link.url).host
  end

  def allowed_host?(host)
    host.present? && !SKIPPED_HOSTS.include?(host)
  end
end
