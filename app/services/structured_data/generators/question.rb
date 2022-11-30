# frozen_string_literal: true

module StructuredData::Generators::Question
  extend self

  def structured_data_for(subject)
    {
      '@context': 'http://schema.org',
      '@type': 'FAQPage',
      'mainEntity': main_entity_from(subject),
    }
  end

  private

  def main_entity_from(subject)
    {
      '@type': 'Question',
      'name': subject.title,
      'acceptedAnswer': accepted_answer_from(subject),
    }
  end

  def accepted_answer_from(subject)
    {
      '@type': 'Answer',
      'text': subject.answer,
    }
  end
end
