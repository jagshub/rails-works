# frozen_string_literal: true

module StructuredData::Generators::Discussion::Thread
  extend self

  def structured_data_for(subject)
    return unless subject.title.include?('?')
    return if subject.comments_count == 0

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
    subject.description
  end

  def answer_count_from(subject)
    subject.comments_count
  end

  def date_created_from(subject)
    subject.created_at
  end

  def author_from(subject)
    ::StructuredData::Types::Person.call(subject.user)
  end

  def accepted_answer_from(subject)
    accepted_answer = subject.comments.by_credible_votes_count.first

    StructuredData::Types::Answer.call(accepted_answer)
  end

  def suggested_answer_from(subject)
    return [] if subject.comments.length < 2

    comments = subject.comments.by_credible_votes_count.first(15).drop(1)

    comments.map { |comment| StructuredData::Types::Answer.call(comment) }.compact
  end
end
