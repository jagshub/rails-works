# frozen_string_literal: true

module Seo::StructuredDataValidator::RuleSets::LegacyProduct
  extend self

  def call_with(data)
    messages = []

    messages << 'Missing Title' if data[:name].blank?
    messages << 'Missing Operation System' if data[:operatingSystem].blank?
    messages << 'Missing Application Category' if data[:applicationCategory].blank?
    messages << 'Missing Offers' if data[:offers].blank?

    messages |= Seo::StructuredDataValidator::RuleSets::AggregateRating.call_with(data[:aggregateRating])

    messages
  end
end
