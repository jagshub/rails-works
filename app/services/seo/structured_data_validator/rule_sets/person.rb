# frozen_string_literal: true

module Seo::StructuredDataValidator::RuleSets::Person
  extend self

  def call_with(data)
    return ['Missing Author'] if data.blank?

    messages = []

    messages << 'Missing Author:Name' if data[:name].blank?
    messages << 'Missing Author:Image' if data[:image].blank?
    messages << 'Missing Author:URL' if data[:url].blank?

    messages
  end
end
