# frozen_string_literal: true

module Sanitizers::Transformers::ExtractAttributes
  extend self

  TAGS_WITH_URL = {
    'a' => %w(href).freeze,
    'img' => %w(src).freeze,
  }.freeze

  def call(node:, node_name:, **)
    return unless TAGS_WITH_URL.key?(node_name)

    target_attributes = TAGS_WITH_URL.fetch(node_name)
    extracted_string = target_attributes
                       .select { |attr| node.attributes[attr].present? }
                       .reduce('') { |acc, attr| "#{ acc } #{ node.attributes[attr] }" }

    node.replace(extracted_string)
  end
end
