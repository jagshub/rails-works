# frozen_string_literal: true

module Products::PlatformUrl
  extend self

  def find(product, platform)
    link =
      LegacyProductLink
      .where(post_id: product.post_ids)
      .public_send(platform)
      .order(created_at: :desc)
      .limit(1)
      .first

    return if link.blank?

    Routes.short_link_url(link.short_code)
  end
end
