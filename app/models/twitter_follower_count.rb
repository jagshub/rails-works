# frozen_string_literal: true

# == Schema Information
#
# Table name: twitter_follower_counts
#
#  id             :bigint(8)        not null, primary key
#  subject_id     :integer          not null
#  subject_type   :string           not null
#  follower_count :integer          default(0), not null
#  last_checked   :datetime         not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_twitter_follower_counts_on_subject_and_id  (subject_id,subject_type) UNIQUE
#
class TwitterFollowerCount < ApplicationRecord
  SUBJECTS = [
    Product,
    User,
  ].freeze

  validates :subject_type, presence: true
  validates :subject_id, presence: true, uniqueness: { scope: %i(subject_id subject_type) }
  validates :follower_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to_polymorphic :subject, allowed_classes: SUBJECTS, inverse_of: :twitter_follower_count
end
