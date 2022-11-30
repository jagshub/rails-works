# frozen_string_literal: true

# == Schema Information
#
# Table name: spam_logs
#
#  id               :bigint(8)        not null, primary key
#  content          :text             not null
#  more_information :jsonb            not null
#  user_id          :bigint(8)
#  kind             :integer          not null
#  content_type     :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  remarks          :string           not null
#  level            :integer          not null
#  parent_log_id    :integer
#  action           :integer          not null
#  false_positive   :boolean          default(FALSE), not null
#
# Indexes
#
#  index_spam_logs_on_content_type  (content_type)
#  index_spam_logs_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_log_id => spam_logs.id)
#  fk_rails_...  (user_id => users.id)
#

class Spam::Log < ApplicationRecord
  include Namespaceable

  belongs_to :user, class_name: '::User', inverse_of: :spam_logs, optional: true
  belongs_to :parent_log, class_name: 'Spam::Log', inverse_of: :child_logs, optional: true
  has_many :child_logs, foreign_key: :parent_log_id, class_name: 'Spam::Log', inverse_of: :parent_log

  enum kind: %i(automatic manual)
  enum content_type: %i(comment post user vote)
  enum level: %i(questionable inappropriate spammer harmful)
  enum action: %i(hide trash delete mark_as_spam mark_as_non_credible alert unmark_as_spam mark_as_credible), _suffix: true

  validates :kind, presence: true
  validates :content, presence: true
  validates :content_type, presence: true
  validates :remarks, presence: true
  validates :action, presence: true
  validates :level, presence: true

  scope :root, -> { where(parent_log_id: nil) }
  scope :with_parent, -> { where.not(parent_log_id: nil) }
  scope :by_username, ->(username) { joins(:user).where('users.username = ?', username) }
  scope :by_author, ->(username) { where(kind: :manual).where('more_information @> ?', { marked_by: username }.to_json) }
  scope :by_subject_type, ->(subject_type) { where('more_information @> ?', { subject_type: subject_type }.to_json) }
  scope :by_subject_id, ->(subject_id) { where('more_information @> ?', { subject_id: subject_id.to_i }.to_json) }

  def self.by_check(actor)
    case actor.to_sym
    when :twitter_suspension then where('more_information @> ?', { marked_by: Spam::Users::Checks::TwitterSuspension::CHECK_NAME }.to_json)
    when :similar_votes then where('more_information @> ?', { failed_checks: ['SimilarVotes'] }.to_json)
    when :sibling_users then where('more_information @> ?', { failed_checks: ['SiblingUsers'] }.to_json)
    when :similar_username then where('more_information @> ?', { failed_checks: ['similar_username'] }.to_json)
    end
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i(by_check by_author by_subject_type by_subject_id by_username)
  end

  def parent?
    parent_log_id.blank?
  end

  def job_payload
    {
      user: user,
      kind: kind.to_s,
      level: level.to_s,
      current_user: more_information['marked_by'] ? User.find_by(username: more_information['marked_by']) : nil,
      parent_log_id: id,
    }
  end
end
