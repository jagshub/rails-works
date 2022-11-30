# frozen_string_literal: true

module Posts::CleanSocialLinks
  extend self

  def call(name:, value: nil)
    return value if value.nil?
    return value if Product::CORRECT_DOMAINS[name].blank?

    slug = value.gsub(%r{https?://[^/]+/}, '').gsub(%r{/$}, '')
    return value if slug.blank?

    "#{ Product::CORRECT_DOMAINS[name] }#{ slug }"
  end
end
