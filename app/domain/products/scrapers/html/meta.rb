# frozen_string_literal: true

module Products::Scrapers::HTML
  class Meta < Base
    # NOTE(DZ): Meta scraper is a catch-all, will match all urls
    def self.match(_uri)
      true
    end

    field :description do
      attribute_from_selector('meta[name="description"]', 'content') ||
        attribute_from_selector('meta[property="og:description"]', 'content')
    end

    field :tagline do
      node = doc.xpath('//title').first
      return if node.blank?

      node.inner_text
    end

    field :name do
      attribute_from_selector('meta[name="application-name"]', 'content') ||
        attribute_from_selector('meta[property="og:site_name"]', 'content')
    end

    field :images do
      images_from_selectors('meta[name="twitter:image"]' => 'content', 'meta[property="og:image"]' => 'content')
    end

    field :logos do
      images_from_selectors(
        'link[rel=apple-touch-icon]' => 'href',
        'link[rel=icon]' => 'href',
        '.logo img' => 'src',
        'img[class*="logo"]' => 'src',
      )
    end

    field :app_store_url do
      href = attribute_from_xpath('//a[contains(@href, "itunes.apple.com/")]', 'href') ||
             attribute_from_xpath('//a[contains(@href, "apps.apple.com/")]', 'href')
      return if href.blank?

      href
    end

    field :play_store_url do
      href = attribute_from_xpath('//a[contains(@href, "play.google.com/")]', 'href')
      return if href.blank?

      href
    end

    field :keywords do
      attribute_from_selector('meta[name="keywords"]', 'content')
    end

    field :twitter_links do
      links_from_selector("a[href*='twitter.com/']")
    end

    field :facebook_links do
      links_from_selector("a[href*='facebook.com/']")
    end

    field :instagram_links do
      links_from_selector("a[href*='instagram.com/']")
    end
  end
end
