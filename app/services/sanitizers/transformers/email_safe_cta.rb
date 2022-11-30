# frozen_string_literal: true

module Sanitizers::Transformers::EmailSafeCta
  extend self

  def call(node:, node_name:, **)
    return unless node_name == 'template'
    return unless node.attributes['type']&.value == 'cta'

    href = Rack::Utils.escape_html(node.attributes['href']&.value)

    html_str = <<~HTML.strip
      <a class="html-input-cta" href="#{ href }" target="_blank" rel="nofollow noopener noreferrer" />
    HTML

    replacement_node = Nokogiri::HTML.fragment(html_str).children[0]
    replacement_node.children = node.children
    node.replace(replacement_node)
  end
end
