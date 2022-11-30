# frozen_string_literal: true

module Seo::StructuredDataValidator::Validator
  extend self

  def generate_for(subject)
    messages = ::Seo::StructuredDataValidator::Validator.for(subject)
    ::SeoStructuredDataValidationMessages.create!(subject: subject, messages: messages) if messages.present?
  end

  def for(subject)
    structured_data = StructuredData::Generator.generator_for(subject)

    return if structured_data.blank?

    supported_types = {
      'WebApplication' => 'LegacyProduct',
      'MobileApplication' => 'LegacyProduct',
      'SoftwareApplication' => 'LegacyProduct',
      'QAPage' => 'Qapage',
      'Event' => 'Event',
      'Article' => 'Article',
    }.freeze

    rule_set = "::Seo::StructuredDataValidator::RuleSets::#{ supported_types[structured_data[:@type]] }".safe_constantize
    raise NotImplementedError, "You must implement a ruleset for #{ subject.class.name }" unless rule_set

    rule_set.call_with(structured_data)
  end
end
