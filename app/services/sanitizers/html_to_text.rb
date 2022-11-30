# frozen_string_literal: true

module Sanitizers::HtmlToText
  #
  # HtmlToText
  #
  # Translates an HTML string into text only,
  #
  # Usage: Sanitizers::HtmlToText.call(html_string)
  # Expected: String
  #

  extend self

  SANITIZE_ALL_OPTIONS = {
    elements: ['html'].freeze,
    transformers: [
      Sanitizers::Transformers::EmailSafeVideos,
      Sanitizers::Transformers::ExtractAttributes,
    ],
  }.freeze

  SANITIZE_WITHOUT_EXTRACT_ATTRIBUTES = {
    elements: ['html'].freeze,
    transformers: [
      Sanitizers::Transformers::EmailSafeVideos,
    ],
  }.freeze

  def call(text, extract_attr: true)
    return if text.nil?

    sanitized_text = Sanitize.fragment(text, extract_attr ? SANITIZE_ALL_OPTIONS : SANITIZE_WITHOUT_EXTRACT_ATTRIBUTES)
    sanitized_text = sanitized_text.gsub(/(\s+|\n)/, ' ').gsub(/\s[,.;]/, '')
    CGI.unescapeHTML(sanitized_text).strip
  end
end
