# frozen_string_literal: true

class MetaTags::Generators::GoldenKitty::Category < MetaTags::Generator
  def canonical_url
    Routes.golden_kitty_category_url(category, category)
  end

  def creator
    '@producthunt'
  end

  def description
    "Product Hunt's annual Golden Kitty Awards #{ category.year }. Nominate your favorite products for #{ category.name } category."
  end

  def image
    image_uuid = GoldenKitty.social_image_for_category(category)
    Image.call(image_uuid) if image_uuid.present?
  end

  def title
    "#{ category.name } - Golden Kitty Awards #{ category.year }"
  end

  private

  def category
    @category ||= subject
  end
end
