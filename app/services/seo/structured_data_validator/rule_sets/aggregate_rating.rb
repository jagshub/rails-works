# frozen_string_literal: true

module Seo::StructuredDataValidator::RuleSets::AggregateRating
  extend self

  def call_with(data)
    return ['Missing Aggregate Rating'] if data.blank?

    messages = []

    messages << 'Missing AggregatedRating:ratingValue' if data[:ratingValue].blank?
    messages << 'Missing AggregatedRating:ratingCount' if data[:ratingCount].blank?

    messages
  end
end
