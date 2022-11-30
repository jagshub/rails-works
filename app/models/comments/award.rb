# frozen_string_literal: true

# == Schema Information
#
# Table name: comment_awards
#
#  id            :bigint(8)        not null, primary key
#  kind          :string           not null
#  comment_id    :bigint(8)        not null
#  awarded_by_id :bigint(8)        not null
#  awarded_to_id :bigint(8)        not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_comment_awards_on_awarded_by_id                    (awarded_by_id)
#  index_comment_awards_on_awarded_by_id_and_awarded_to_id  (awarded_by_id,awarded_to_id) UNIQUE
#  index_comment_awards_on_awarded_to_id                    (awarded_to_id)
#  index_comment_awards_on_comment_id                       (comment_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (awarded_by_id => users.id)
#  fk_rails_...  (awarded_to_id => users.id)
#  fk_rails_...  (comment_id => comments.id)
#
class Comments::Award < ApplicationRecord
  self.table_name = 'comment_awards'
  belongs_to :comment, inverse_of: :award

  belongs_to :awarded_to, class_name: 'User'
  belongs_to :awarded_by, class_name: 'User'

  enum kind: {
    great_question: 'great_question',
    great_feedback: 'great_feedback',
    great_support: 'great_support',
    great_example: 'great_example',
  }

  validate :ensure_no_self_awards
  before_validation :set_awarded_to

  private

  def ensure_no_self_awards
    return if awarded_by_id.nil? || awarded_to_id.nil?

    errors.add(:awarded_to, "can't be same as awarded_by") if awarded_by_id == awarded_to_id
  end

  def set_awarded_to
    self.awarded_to = comment.user if comment.present?
  end
end
