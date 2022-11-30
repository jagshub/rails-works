# frozen_string_literal: true

class BetterFormatter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper

  ALLOWED_ELEMENTS = %w(
    a
    b
    br
    div
    em
    h1
    h2
    h3
    h4
    h5
    h6
    i
    img
    li
    ol
    p
    strong
    ul
    template
  ).freeze

  class << self
    def call(text, mode:)
      return if text.nil?

      new(text, mode).call
    end

    def mode_with_processors
      {
        strict: %i(change_urls_to_text_links),
        simple: %i(change_urls_to_links),
        simple_with_usernames: %i(change_urls_to_links change_usernames_to_links),
        full: %i(change_urls_to_links change_usernames_to_links convert_youtube_links convert_vimeo_links),
      }
    end

    def strip_tags(text)
      ActionController::Base.helpers.strip_tags(text)
    end
  end

  def initialize(text, mode)
    @text = text.strip
    @mode = mode
  end

  def call
    return '' if @text.blank?

    sanitize_around do
      processors.each do |method|
        send method
      end
    end
  end

  private

  def sanitize_around(&block)
    @text = sanitize_with_mode(:strict)
    block.call
    @text = sanitize_with_mode(:loose)
  end

  def processors
    self.class.mode_with_processors.fetch @mode
  end

  def change_urls_to_text_links
    @text = auto_link @text, link: :all, sanitize: false do |url|
      truncate_non_video_urls(url)
    end
  end

  def change_urls_to_links
    @text = auto_link @text, link: :all, sanitize: false do |url|
      image_url?(url) ? image_tag(url) : truncate_non_video_urls(url)
    end
  end

  def truncate_non_video_urls(url)
    return url if url =~ %r{https?://(www\.)?vimeo.com/(\d+)}
    return url if url =~ %r{https?://(www\.)?youtu(\.be|be\.com)/watch(\?v=|[^<]+\&v=)([^<&]+)[^<]*}

    truncate(url, length: 35)
  end

  def change_usernames_to_links
    # Auto link Twitter Handles
    # Note(andreasklinger): '/@abc' is explicitly not matched by the regex
    #   to allow weird medium urls.
    @text.gsub!(%r{(^|[^/\w])@(\w+)\b}) do |match|
      whitespace, handle = match.split('@')

      whitespace + %(<a href="#{ Routes.profile_url(handle, protocol: 'https') }" target="_blank">@#{ handle }</a>)
    end
  end

  def convert_youtube_links
    # NOTE(ayrton) links are already autolinked
    @text.gsub! %r{<a[^>]+>https?://(www\.)?youtu(\.be|be\.com)/watch(\?v=|[^<]+\&v=)([^<&]+)[^<]*</a>} do
      id = Regexp.last_match[4]
      %(<div class="media m-video"><iframe width="420" height="315" src="//www.youtube.com/embed/#{ id }?autohide=1&showinfo=0" frameborder="0" allowfullscreen></iframe></div>)
    end
  end

  def convert_vimeo_links
    # NOTE(ayrton) links are already autolinked
    @text.gsub! %r{<a[^>]+>https?://(www\.)?vimeo.com/(\d+)</a>} do
      id = Regexp.last_match[2]
      %(<div class="media m-video"><iframe width="420" height="315" src="//player.vimeo.com/video/#{ id }" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe></div>)
    end
  end

  def sanitize_with_mode(mode = :strict)
    sanitize_opts = mode == :strict ? strict_sanitize_options : loose_sanitize_options
    Sanitize.fragment(@text, sanitize_opts)
  end

  def strict_sanitize_options
    {
      elements: ALLOWED_ELEMENTS,
      remove_contents: %w(script),
      attributes: {
        'img' => %w(src width height),
        'a' => %w(href),
        'template' => %w(type variant src caption),
      },
      protocols: { 'a' => { 'href' => %w(http https mailto) } },
      transformers: [BetterFormatter::MediaCamoTransformer],
    }
  end

  def loose_sanitize_options
    {
      elements: ALLOWED_ELEMENTS + %w(iframe),
      remove_contents: %w(script),
      attributes: {
        'img' => %w(src width height),
        'a' => %w(href),
        'div' => %w(class),
        'iframe' => %w(webkitallowfullscreen mozallowfullscreen allowfullscreen frameborder height src width),
        'template' => %w(type variant src caption),
      },
      # Note(andreasklinger): max-width is used for the emails - this can be removed when we switch to autoinlining css in emails
      add_attributes: {
        'a' => { 'target' => '_blank', 'rel' => 'nofollow noopener noreferrer' },
        'img' => { 'style' => 'max-width: 100%' },
      },
      protocols: { 'a' => { 'href' => %w(http https mailto) } },
      transformers: [BetterFormatter::MediaCamoTransformer],
    }
  end

  def image_url?(url)
    path = URI.parse(url).path
    path.present? && path[/\.(png|jpe?g|gif)$/i]
  rescue URI::InvalidURIError
    false
  end
end
