# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_question_answers
#
#  id                               :integer          not null, primary key
#  upcoming_page_question_option_id :integer
#  upcoming_page_subscriber_id      :integer          not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  upcoming_page_question_id        :integer
#  freeform_text                    :text
#  kind                             :integer          default("option"), not null
#
# Indexes
#
#  index_subscriber_id_question_option_id                   (upcoming_page_subscriber_id,upcoming_page_question_option_id)
#  index_upcoming_question_answers_on_upcoming_question_id  (upcoming_page_question_id)
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_question_id => upcoming_page_questions.id)
#  fk_rails_...  (upcoming_page_question_option_id => upcoming_page_question_options.id)
#  fk_rails_...  (upcoming_page_subscriber_id => upcoming_page_subscribers.id)
#

class UpcomingPageQuestionAnswer < ApplicationRecord
  belongs_to :option, class_name: 'UpcomingPageQuestionOption', foreign_key: :upcoming_page_question_option_id, inverse_of: :answers, optional: true
  belongs_to :question, class_name: 'UpcomingPageQuestion', foreign_key: :upcoming_page_question_id, inverse_of: :answers, optional: true
  belongs_to :subscriber, class_name: 'UpcomingPageSubscriber', foreign_key: :upcoming_page_subscriber_id, inverse_of: :answers

  attr_readonly :upcoming_page_question_option_id, :upcoming_page_subscriber_id

  delegate :survey_title, :upcoming_page_survey_id, :survey, to: :question
  delegate :name, to: :subscriber, prefix: true

  enum kind: {
    option: 0,
    freeform: 100,
    other: 200,
  }

  def upcoming_page
    question.survey.upcoming_page
  end

  def value
    freeform_text.presence || option&.title || ''
  end
end
