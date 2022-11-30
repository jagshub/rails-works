# frozen_string_literal: true

module Sharing::ImageUrl
  extend self

  NO_IMAGE = [
    'Badge',
    'ChangeLog::Entry',
    'Collection',
    'Discussion::Thread',
    'Job',
    'Newsletter',
    'Topic',
    'User',
  ].freeze

  DELEGATES = {
    'UpcomingPageMessage' => 'upcoming_page',
    'UpcomingPageSurvey' => 'upcoming_page',
  }.freeze

  def call(subject)
    return if no_image?(subject)

    subject = subject.public_send(DELEGATES[subject.class.name]) if DELEGATES.include?(subject.class.name)

    generator = FindConst.call(Sharing::ImageUrl, subject)
    generator.call(subject)
  end

  private

  def no_image?(subject)
    NO_IMAGE.include?(subject.class.name)
  end
end
