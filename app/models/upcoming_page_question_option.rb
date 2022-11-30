# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_question_options
#
#  id                        :integer          not null, primary key
#  title                     :string           not null
#  upcoming_page_question_id :integer          not null
#  trashed_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_question_id => upcoming_page_questions.id)
#

class UpcomingPageQuestionOption < ApplicationRecord
  include Trashable

  belongs_to :question, class_name: 'UpcomingPageQuestion', foreign_key: :upcoming_page_question_id

  has_many :answers, class_name: 'UpcomingPageQuestionAnswer', dependent: :delete_all, inverse_of: :option
  has_many :subscribers, class_name: 'UpcomingPageSubscriber', through: :answers
  has_many :dependent_rules, class_name: 'UpcomingPageQuestionRule', dependent: :delete_all, foreign_key: :dependent_upcoming_page_option_id

  validates :title, presence: true

  scope :by_created_at, -> { order('created_at ASC') }

  attr_readonly :upcoming_page_question_id
end
