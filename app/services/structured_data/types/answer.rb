# frozen_string_literal: true

module StructuredData::Types::Answer
  extend self

  def call(subject)
    return if subject.nil?

    {
      '@type': 'Answer',
      'text': subject.body,
      'dateCreated': subject.created_at,
      'upvoteCount': subject.votes_count || 0,
      'url': Routes.subject_url(subject),
      'author': StructuredData::Types::Person.call(subject.user),
    }
  end
end
