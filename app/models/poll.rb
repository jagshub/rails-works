# frozen_string_literal: true

# == Schema Information
#
# Table name: polls
#
#  id            :bigint(8)        not null, primary key
#  subject_type  :string           not null
#  subject_id    :bigint(8)        not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  options_count :integer          default(0), not null
#  answers_count :integer          default(0), not null
#
# Indexes
#
#  index_polls_on_subject  (subject_type,subject_id)
#

class Poll < ApplicationRecord
  include ExplicitCounterCache

  belongs_to :subject, polymorphic: true, inverse_of: :poll

  has_many :options, class_name: 'PollOption', dependent: :destroy
  has_many :ordered_options, -> { order(id: :asc) }, class_name: 'PollOption'
  has_many :answers, through: :options, source: :answers

  explicit_counter_cache :answers_count, -> { answers }
end
