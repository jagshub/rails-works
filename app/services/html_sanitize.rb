# frozen_string_literal: true

# This is there to clean/sanitize STATIC html fragments and hasn't been
# tested with XHR exploits. It's meant to be used internally
# in our admin interface.
module HtmlSanitize
  extend self

  def call(html_fragment)
    return if html_fragment.nil?

    Nokogiri::HTML::DocumentFragment.parse(html_fragment).to_html(encoding: 'UTF-8')
  end
end
