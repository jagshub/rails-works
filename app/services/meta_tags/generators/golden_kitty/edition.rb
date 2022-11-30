# frozen_string_literal: true

class MetaTags::Generators::GoldenKitty::Edition < MetaTags::Generator
  def canonical_url
    Routes.golden_kitty_edition_url(edition)
  end

  def creator
    '@producthunt'
  end

  def description
    "Product Hunt's annual Golden Kitty Awards. Nominate your favorite products from #{ year }."
  end

  def image
    image_uuid = GoldenKitty.social_image_for_edition(edition)
    Image.call(image_uuid) if image_uuid.present?
  end

  def title
    "Golden Kitty Awards #{ year }"
  end

  private

  def edition
    @edition ||= subject
  end

  def year
    edition.year
  end
end
