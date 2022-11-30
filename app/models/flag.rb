# frozen_string_literal: true

# == Schema Information
#
# Table name: flags
#
#  id                :integer          not null, primary key
#  subject_type      :text             not null
#  subject_id        :integer          not null
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  status            :string           default("unresolved"), not null
#  reason            :string           not null
#  moderator_id      :bigint(8)
#  other_flags_count :integer          default(0), not null
#
# Indexes
#
#  index_flags_on_moderator_id  (moderator_id)
#  index_flags_on_reason        (reason) USING spgist
#  index_flags_on_status        (status) USING spgist
#  index_flags_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (moderator_id => users.id)
#

class Flag < ApplicationRecord
  include ExplicitCounterCache

  SUBJECTS = [
    Comment,
    Post,
    ProductRequest,
    Recommendation,
    User,
    Review,
    Product,
    Team::Invite,
    Team::Request,
  ].freeze

  explicit_counter_cache :other_flags_count, lambda {
    subject.user_flags.where.not(id: id)
  }

  before_create :increment_other_user_flags
  before_destroy :decrement_other_user_flags

  belongs_to :user, optional: true
  belongs_to :moderator, class_name: 'User', optional: true
  belongs_to_polymorphic :subject,
                         counter_cache: :user_flags_count,
                         allowed_classes: SUBJECTS

  validates :subject_id, presence: true
  validates :subject_type, presence: true
  validates :reason, presence: true

  enum reason: {
    duplicate: 'duplicate',
    harmful: 'harmful',
    incomplete: 'incomplete',
    self_promotion: 'self_promotion',
    spam: 'spam',
  }

  enum status: {
    resolved: 'resolved',
    unresolved: 'unresolved',
  }

  scope :urgent, -> { harmful.or(spam) }
  scope :other, -> { where.not(arel_table[:reason].in(%w(harmful spam))) }

  def subject_deleted?
    subject.nil?
  end

  private

  # NOTE(DZ): Before create, subject's user_flags_count should be 1 less
  # than the resulting value.
  def increment_other_user_flags
    subject_user_flags_count = subject.user_flags_count
    subject.user_flags.update_all other_flags_count: subject_user_flags_count
    self[:other_flags_count] = subject_user_flags_count
  end

  # NOTE(DZ): Before destroy, subject's user_flags_count should be 1 more than
  # the resulting value, and 2 more than the desired other_flags_count
  def decrement_other_user_flags
    subject_user_flags_count = subject.user_flags_count - 2
    subject.user_flags.where.not(id: id).update_all(
      other_flags_count: subject_user_flags_count,
    )
  end
end
