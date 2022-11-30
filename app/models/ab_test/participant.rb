# frozen_string_literal: true

# == Schema Information
#
# Table name: ab_test_participants
#
#  id           :bigint(8)        not null, primary key
#  variant      :string           not null
#  user_id      :bigint(8)
#  visitor_id   :string
#  anonymous_id :string
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  test_name    :string
#
# Indexes
#
#  index_ab_test_participants_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AbTest::Participant < ApplicationRecord
  include Namespaceable

  validates :variant, presence: true
  validate :user_or_guest_tracking

  belongs_to :user, class_name: '::User', optional: true, inverse_of: :ab_test_participants

  private

  def user_or_guest_tracking
    errors.add(:base, 'requires either user or visitor_id') if user_id.blank? && visitor_id.blank? && anonymous_id.blank?
  end
end
