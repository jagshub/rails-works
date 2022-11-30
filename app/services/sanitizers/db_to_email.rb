# frozen_string_literal: true

module Sanitizers::DbToEmail
  #
  # DbToEmail
  #
  # Translates a DB HTML string into an email safe html string
  # This process will transform a html string that contains custom components
  # This includes
  #   <template type="video".../>
  #
  # Usage: Sanitizers::DbToEmail.call(html_string)
  # Expected: String
  #

  extend self

  SANITIZE_OPTIONS = {
    elements: %w(div br strong b span em i u h1 hr strike del img a p ol ul li).freeze,
    remove_contents: %w(script),
    attributes: {
      'img' => %w(src width height alt),
      'a' => %w(href target rel class),
    },
    add_attributes: {
      'a' => {
        'target' => '_blank',
        'rel' => 'nofollow noopener noreferrer',
      },
    },
    output: :xhtml,
    protocols: { 'a' => { 'href' => %w(http https mailto) } },
    transformers: [
      BetterFormatter::MediaCamoTransformer,
      Sanitizers::Transformers::EmailSafeVideos,
      Sanitizers::Transformers::EmailSafeCta,
      Sanitizers::Transformers::EmailSafePlaceholder,
    ],
    context: {}.freeze,
  }.freeze

  def call(html, context: {})
    return if html.nil?
    return '' if html.blank?

    options = SANITIZE_OPTIONS.merge(context: context)
    html = Sanitize.fragment(html, options)
    html.gsub(/\n\s*/, '').strip
  end
end
