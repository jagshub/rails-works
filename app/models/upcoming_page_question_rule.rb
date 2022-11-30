# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_question_rules
#
#  id                                  :integer          not null, primary key
#  upcoming_page_question_id           :integer          not null
#  dependent_upcoming_page_option_id   :integer          not null
#  dependent_upcoming_page_question_id :integer          not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_upcoming_page_question_rules_on_upcoming_page_question_id  (upcoming_page_question_id)
#

class UpcomingPageQuestionRule < ApplicationRecord
  belongs_to :question, class_name: 'UpcomingPageQuestion', foreign_key: :upcoming_page_question_id, inverse_of: :rules

  belongs_to :dependent_question, class_name: 'UpcomingPageQuestion', foreign_key: :dependent_upcoming_page_question_id
  belongs_to :dependent_option, class_name: 'UpcomingPageQuestionOption', foreign_key: :dependent_upcoming_page_option_id
end
