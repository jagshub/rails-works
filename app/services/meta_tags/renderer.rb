# frozen_string_literal: true

class MetaTags::Renderer
  include ActionView::Helpers::TagHelper

  attr_reader :meta_tags

  class << self
    def call(url:, meta_tags: {})
      new(url: url, meta_tags: meta_tags).call
    end
  end

  def initialize(url:, meta_tags: {})
    @meta_tags = meta_tags.reverse_merge! default_tags(url)
  end

  def call
    tags = content_tag(:title, meta_tags[:title]) +
           tag(:link, rel: 'canonical', href: meta_tags[:canonical_url]) +
           tag(:meta, 'http-equiv' => 'Content-Type', content: 'text/html; charset=UTF-8') +
           tag(:meta, name: 'description',         content: meta_tags[:description]) +
           tag(:meta, property: 'fb:app_id',       content: Config.secret(:facebook_app_id))

    tags += twitter_tags
    tags += open_graph_tags
    tags += oembed_tags

    tags += tag(:meta, name: 'robots', content: meta_tags[:robots]) if meta_tags[:robots].present?

    tags
  end

  private

  def open_graph_tags
    og_tags = tag(:meta, property: 'og:site_name',    content: 'Product Hunt') +
              tag(:meta, property: 'og:title',        content: meta_tags[:title]) +
              tag(:meta, property: 'og:type',         content: meta_tags[:type]) +
              tag(:meta, property: 'og:image',        content: meta_tags[:image]) +
              tag(:meta, property: 'og:description',  content: meta_tags[:description]) +
              tag(:meta, property: 'og:locale',       content: 'en_US') +
              tag(:meta, property: 'og:url',          content: meta_tags[:canonical_url])

    og_tags
  end

  # Documentation: https://dev.twitter.com/cards/types/summary-large-image
  def twitter_tags
    twitter_tags = tag(:meta, name: 'twitter:card',        content: 'summary_large_image') +
                   tag(:meta, name: 'twitter:site',        content: '@producthunt') +
                   tag(:meta, name: 'twitter:title',       content: meta_tags[:title]) +
                   tag(:meta, name: 'twitter:description', content: meta_tags[:description]) +
                   tag(:meta, name: 'twitter:image',       content: meta_tags[:image]) +
                   tag(:meta, name: 'twitter:creator',     content: meta_tags[:creator])

    twitter_tags
  end

  def oembed_tags
    oembed_tags = ''
    if meta_tags[:oembed_url]
      oembed_tags = tag(
        :link,
        rel: 'alternate',
        type: 'application/json+oembed',
        href: "https://api.producthunt.com/widgets/oembed?url=#{ Addressable::URI.encode(meta_tags[:oembed_url]) }",
      )
    end
    oembed_tags
  end

  def default_tags(url)
    {
      canonical_url: url,
      image: Screenshot.new(url).image_url,
      type: 'article',
      title: 'Product Hunt',
      creator: '@producthunt',
      description: 'Product Hunt is a curation of the best new products, every day. Discover the ' \
                   "latest mobile apps, websites, and technology products that everyone's talking about.",
    }
  end
end
