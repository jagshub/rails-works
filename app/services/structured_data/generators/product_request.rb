# frozen_string_literal: true

module StructuredData::Generators::ProductRequest
  extend self

  def structured_data_for(subject)
    return if subject.recommended_products_count == 0

    {
      '@context': 'http://schema.org',
      '@type': 'QAPage',
      'mainEntity': main_entity_from(subject),
    }
  end

  private

  def main_entity_from(subject)
    {
      '@type': 'Question',
      'name': name_from(subject),
      'text': text_from(subject),
      'answerCount': answer_count_from(subject),
      'dateCreated': date_created_from(subject),
      'author': author_from(subject),
      'acceptedAnswer': accepted_answer_from(subject),
      'suggestedAnswer': suggested_answer_from(subject),
    }
  end

  def name_from(subject)
    subject.title
  end

  def text_from(subject)
    subject.body
  end

  def answer_count_from(subject)
    subject.recommended_products_count
  end

  def date_created_from(subject)
    subject.created_at
  end

  def author_from(subject)
    ::StructuredData::Types::Person.call(subject.user)
  end

  def accepted_answer_from(subject)
    accepted_answer = subject.recommendations.by_credible_votes_count.first

    StructuredData::Types::Answer.call(accepted_answer)
  end

  def suggested_answer_from(subject)
    return [] if subject.recommendations.length < 2

    recommendations = subject.recommendations.by_credible_votes_count.drop(1)

    recommendations.map { |recomendation| StructuredData::Types::Answer.call(recomendation) }.compact
  end
end
