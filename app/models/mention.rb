# frozen_string_literal: true

# == Schema Information
#
# Table name: mentions
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  subject_type :text             not null
#  subject_id   :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_mentions_on_user_id_and_subject_type_and_subject_id  (user_id,subject_type,subject_id) UNIQUE
#

class Mention < ApplicationRecord
  belongs_to :subject, polymorphic: true, optional: false
  belongs_to :user, touch: true, optional: false

  validates :user_id, uniqueness: { scope: %i(subject_type subject_id) }

  scope :created_after, ->(date) { where(arel_table[:created_at].gteq(date)) }

  # NOTE(nvalchanov): Remove mentions with invalid subject (chat)
end
