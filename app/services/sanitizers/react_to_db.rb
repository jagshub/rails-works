# frozen_string_literal: true

module Sanitizers::ReactToDb
  #
  # ReactToDb
  #
  # Translates an react HTML string into database html
  # This module will also apply some transformations based on the mode specified
  # See constant TRANSFORM_MODES
  #
  # Usage: Sanitizers::ReactToDb.call(html_string, mode: [...])
  # Expected: String
  #
  extend self
  extend ActionView::Helpers::TextHelper
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::UrlHelper
  extend ActionView::Helpers::AssetTagHelper

  SANITIZE_OPTIONS = {
    elements: %w(div iframe span br blockquote strong b em i u h1 h2 h3 hr strike del img a p ol ul li template).freeze,
    remove_contents: %w(script),
    attributes: {
      # Note(DavidZhang): Custom elements tag attribtues
      'template' => %w(type video-id src caption variant type username text tweet-id instagram-post-id kind fallback href),
      'img' => %w(src width height alt),
      'a' => %w(href target rel class),
    },
    output: :xhtml,
    add_attributes: {
      'a' => {
        'target' => '_blank',
        'rel' => 'nofollow noopener noreferrer',
      },
    },
    protocols: { 'a' => { 'href' => %w(http https mailto) } },
    transformers: [BetterFormatter::MediaCamoTransformer],
  }.freeze

  TRANSFORM_MODES = {
    none: %i(),
    url_and_username: %i(
      change_urls_to_links
      change_usernames_to_links
    ),
    url_and_youtube: %i(
      change_urls_to_links
      convert_youtube_links
    ),
    everything: %i(
      change_urls_to_links
      change_usernames_to_links
      convert_youtube_links
    ),
  }.freeze

  def call(html, mode: :none)
    return if html.nil?

    html = html.strip
    return '' if html.blank?

    html = additional_transformations(html, mode)
    Sanitize.fragment(html, SANITIZE_OPTIONS)
  end

  private

  def additional_transformations(html, mode)
    transforms = TRANSFORM_MODES.fetch mode
    transforms.reduce(html) { |acc, method| send method, acc }
  end

  def change_urls_to_links(html)
    # Note(DavidZhang): autolink params affect each other because rails_autolink
    #   is written poorly. link must be set to :all for the correct option block
    #   https://github.com/tenderlove/rails_autolink/blob/master/lib/rails_autolink/helpers.rb#L64
    auto_link html, link: :all, sanitize: false do |url|
      image_url?(url) ? image_tag(url) : truncate_non_video_urls(url)
    end
  end

  def sanitize(string)
    string
  end

  YOUTUBE_REGEX = %r{
    https?://(www\.)?
    youtu(\.be|be\.com)
    /watch(\?v=|[^<]+\&v=)([^<&]+)[^<]*
  }x.freeze

  def change_usernames_to_links(html)
    # Note(andreasklinger): '/@abc' is explicitly not matched by the regex
    #   to allow weird medium urls.
    html.gsub(%r{(^|[^/\w])\@(\w+)\b}) do |match|
      whitespace, handle = match.split('@')
      href = if User.visible.where(username: handle.downcase).exists?
               'https://www.producthunt.com/@' + handle
             else
               'https://twitter.com/' + handle
             end

      whitespace + %(<a href="#{ href }" target="_blank">@#{ handle }</a>)
    end
  end

  YOUTUBE_MATCH_REGEX = %r{
    <a[^>]+>
    https?://(www\.)?
    youtu(\.be|be\.com)
    /watch(\?v=|[^<]+\&v=)([^<&]+)[^<]*</a>
  }x.freeze

  def convert_youtube_links(html)
    html.gsub YOUTUBE_MATCH_REGEX do
      id = Regexp.last_match[4]
      <<~HTML.strip
        <template type="video" video-id="#{ id }"></template>
      HTML
    end
  end

  def image_url?(url)
    path = URI.parse(url).path
    path.present? && path[/\.(png|jpe?g|gif)$/i]
  rescue URI::InvalidURIError
    false
  end

  def truncate_non_video_urls(url)
    return url if url =~ YOUTUBE_REGEX

    truncate(url, length: 35)
  end
end
