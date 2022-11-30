# frozen_string_literal: true

# == Schema Information
#
# Table name: spam_reports
#
#  id                 :bigint(8)        not null, primary key
#  spam_action_log_id :bigint(8)        not null
#  user_id            :bigint(8)        not null
#  check              :integer          not null
#  action_taken       :integer
#  handled_by_id      :bigint(8)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_spam_reports_on_handled_by_id       (handled_by_id)
#  index_spam_reports_on_spam_action_log_id  (spam_action_log_id)
#  index_spam_reports_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (handled_by_id => users.id)
#  fk_rails_...  (spam_action_log_id => spam_action_logs.id)
#  fk_rails_...  (user_id => users.id)
#

class Spam::Report < ApplicationRecord
  include Namespaceable

  belongs_to :action_log, class_name: '::Spam::ActionLog', foreign_key: :spam_action_log_id, inverse_of: :reports
  belongs_to :user, class_name: '::User', inverse_of: :spam_reports
  belongs_to :handled_by, class_name: '::User', inverse_of: :handled_spam_reports, optional: true

  enum check: {
    user: 0,
    activity: 1,
  }

  enum action_taken: {
    marked_spam: 0,
    marked_false_positive: 1,
  }

  scope :not_handled, -> { where(handled_by_id: nil, action_taken: nil) }
  scope :activity_reports, -> { where(check: 'activity').not_handled }
  scope :user_reports, lambda {
    join_sql = ActiveRecord::Base.sanitize_sql_for_conditions([
                                                                'select distinct on (user_id) spam_reports.* from spam_reports
                                                                where spam_reports.check=? and handled_by_id is null', checks[:user]
                                                              ])
    joins(<<-SQL)
      INNER JOIN (
    #{ join_sql }
      ) spam_user_reports on spam_user_reports.id = spam_reports.id
    SQL
  }

  class << self
    # Note(Rahul): Below methods are used for active admin filters
    def rule_name_eq(rule_id)
      joins(:action_log)
        .merge(::Spam::ActionLog.where(spam_ruleset_id: rule_id))
    end

    def post_id_equals(post_id)
      joins(:action_log)
        .merge(::Spam::ActionLog
        .where(subject_type: 'Vote', subject_id: Post.find(post_id).votes))
    end

    def ransackable_scopes(_auth_object = nil)
      %i(post_id_equals rule_name_eq)
    end
  end
end
