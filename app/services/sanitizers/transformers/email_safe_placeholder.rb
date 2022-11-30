# frozen_string_literal: true

module Sanitizers::Transformers::EmailSafePlaceholder
  extend self

  def call(node:, node_name:, config:, **)
    return unless node_name == 'template'
    return unless node.attributes['type']&.value == 'placeholder'

    kind = node.attributes['kind']&.value
    fallback = node.attributes['fallback']&.value
    context = config[:context]

    content = extract_content(context, kind, fallback)
    html_str = <<~HTML.strip
      <span>#{ Rack::Utils.escape_html(content) }</span>
    HTML

    node.replace(Nokogiri::HTML.fragment(html_str).children[0])
  end

  private

  def extract_content(context, kind, fallback)
    return fallback unless context.present? && kind.present?

    send(kind.underscore, context) || fallback
  end

  def first_name(context)
    context[:user]&.first_name
  end

  def last_name(context)
    context[:user]&.last_name
  end

  def full_name(context)
    context[:user]&.name
  end
end
