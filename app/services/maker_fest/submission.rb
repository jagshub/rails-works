# frozen_string_literal: true

module MakerFest::Submission
  extend self

  CATEGORY = 2424
  EXTERNAL_URL = 2425
  UPCOMING_PAGE = 2507
  VOTING_CLOSE_DATETIME = '2018-12-01 23:00:00'

  CATEGORIES = {
    'Social Impact' => 'social',
    'Voice & Audio' => 'voice',
    'Health & Beauty' => 'health',
    'Inclusion' => 'inclusion',
    'Brain Stuff' => 'brain',
    'Remote Workers' => 'remote',
    'Other' => 'other',
  }.freeze

  def call(answers)
    data = {}

    answers.each do |answer|
      question_id = answer.upcoming_page_question_id
      value = answer.value

      if question_id == CATEGORY
        data[:category_slug] = CATEGORIES[value]
      elsif question_id == EXTERNAL_URL
        data[:url] = value
      else
        slug = ExtractSlug.from_url value, 'upcoming'
        data[:upcoming_page] = UpcomingPage.find_by!(slug: slug.split('/').first)
      end
    end

    data
  end

  def voting_ended?
    Time.zone.now >= Time.zone.parse(VOTING_CLOSE_DATETIME)
  end
end
