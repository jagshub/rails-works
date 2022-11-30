# frozen_string_literal: true

module Seo::StructuredDataValidator::RuleSets::Article
  extend self
  def call_with(data)
    messages = []

    messages << 'Missing Headline' if data[:headline].blank?
    messages << 'Missing Image' if data[:image].blank?
    messages << 'Missing Publisher' if data[:publisher].blank?
    messages << 'Missing Description' if data[:description].blank?
    messages << 'Missing Date Published' if data[:datePublished].blank?
    messages << 'Missing Date Modified' if data[:dateModified].blank?

    messages |= Seo::StructuredDataValidator::RuleSets::Person.call_with(data[:author])

    messages
  end
end
