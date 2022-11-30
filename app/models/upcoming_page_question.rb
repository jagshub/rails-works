# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_questions
#
#  id                      :integer          not null, primary key
#  title                   :string           not null
#  trashed_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  upcoming_page_survey_id :integer          not null
#  position_in_survey      :integer          default(0), not null
#  question_type           :integer          default("single_select"), not null
#  include_other           :boolean          default(FALSE), not null
#  description             :string
#  required                :boolean          default(FALSE), not null
#
# Indexes
#
#  index_upcoming_page_questions_on_upcoming_page_survey_id  (upcoming_page_survey_id)
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_survey_id => upcoming_page_surveys.id)
#

class UpcomingPageQuestion < ApplicationRecord
  include Trashable

  belongs_to :survey, class_name: 'UpcomingPageSurvey', foreign_key: :upcoming_page_survey_id, inverse_of: :questions

  has_many :options, class_name: 'UpcomingPageQuestionOption', dependent: :destroy, inverse_of: :question
  has_many :answers, class_name: 'UpcomingPageQuestionAnswer', dependent: :delete_all, inverse_of: :question

  has_many :rules, class_name: 'UpcomingPageQuestionRule', dependent: :delete_all, inverse_of: :question
  has_many :dependent_rules, class_name: 'UpcomingPageQuestionRule', dependent: :delete_all, foreign_key: :dependent_upcoming_page_question_id

  validates :title, presence: true

  scope :by_created_at, -> { order('created_at ASC') }
  scope :by_position, -> { order('position_in_survey ASC').order('id ASC') }

  acts_as_list scope: :upcoming_page_survey, column: :position_in_survey, top_of_list: 0

  attr_readonly :upcoming_page_survey_id

  enum question_type: {
    single_select: 0,
    multiple_select: 100,
    freeform: 200,
  }

  delegate :title, to: :survey, prefix: true

  def refresh_rules
    return dependent_rules.delete_all if freeform?

    dependent_rules.each do |rule|
      rule.destroy if rule.question.position_in_survey < position_in_survey
    end

    rules.each do |rule|
      rule.destroy if rule.dependent_question.position_in_survey > position_in_survey
    end
  end
end
