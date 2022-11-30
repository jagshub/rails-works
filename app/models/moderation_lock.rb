# frozen_string_literal: true

# == Schema Information
#
# Table name: moderation_locks
#
#  id           :bigint(8)        not null, primary key
#  expires_at   :datetime         not null
#  subject_type :string           not null
#  subject_id   :bigint(8)        not null
#  user_id      :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_moderation_locks_on_subject  (subject_type,subject_id) UNIQUE
#  index_moderation_locks_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ModerationLock < ApplicationRecord
  belongs_to :subject, polymorphic: true
  belongs_to :user, inverse_of: :moderation_locks

  scope :expired, -> { where('expires_at < NOW()') }

  def self.clear_expired_locks
    expired.destroy_all
  end

  def self.unlock_all(user:, type:)
    where(user: user, subject_type: type).destroy_all
  end

  def self.take_first(scope, user:)
    clear_expired_locks

    HandleRaceCondition.call do
      existing_lock = find_by(user: user, subject_type: scope.model_name.name)
      return existing_lock.subject if existing_lock

      subject = first_unlocked(scope)
      return if subject.nil?

      ModerationLock.create!(subject: subject, user: user, expires_at: 1.hour.from_now)
      subject
    end
  end

  def self.first_unlocked(scope)
    join_sql = %(
        LEFT JOIN moderation_locks
        #{ ActiveRecord::Base.sanitize_sql_for_conditions([
                                                            "ON moderation_locks.subject_id = #{ scope.table_name }.id
                                                            AND moderation_locks.subject_type = ?", scope.model_name.name.to_s
                                                          ]) }
    )
    scope
      .where('moderation_locks.id' => nil)
      .joins(join_sql)
      .first
  end
end
