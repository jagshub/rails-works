# frozen_string_literal: true

# == Schema Information
#
# Table name: moderation_logs
#
#  id             :integer          not null, primary key
#  reference_id   :integer          not null
#  reference_type :string           not null
#  moderator_id   :integer          not null
#  message        :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  reason         :text
#  share_public   :boolean          default(FALSE), not null
#
# Indexes
#
#  index_moderation_logs_on_reference_id_and_reference_type  (reference_id,reference_type)
#

class ModerationLog < ApplicationRecord
  belongs_to :reference, polymorphic: true
  belongs_to :moderator, class_name: 'User'

  validates :message, presence: true

  scope :with_preloads, -> { preload(:moderator) }
  scope :share_public, -> { where share_public: true }

  REVIEWED_MESSAGE = 'Marked as reviewed'
  REVIEWED_IN_ADMIN_MESSAGE = 'Marked as reviewed in admin'
  UNFEATURE_MESSAGE = 'Removed post from the homepage'
  FEATURE_MESSAGE = 'Added post to the homepage'
  SCHEDULE_MESSAGE = 'Scheduled post for the homepage'
  SEO_MODERATED_MESSAGE = 'SEO keywords updated'
  APPROVED_THREAD = 'Thread approved'
  REJECTED_THREAD = 'Thread rejected'
  MERGED_PRODUCTS = 'Merged products'
  APPROVED_DUP_POST = 'Approved duplicate post request'
  REJECTED_DUP_POST = 'Rejected duplicate post request'
  OFFLINE = 'No longer online'

  def self.exclude_moderated(scope, message = nil)
    join_sql = %(
        LEFT JOIN moderation_logs ON
        moderation_logs.reference_id=#{ scope.table_name }.id
        #{ ActiveRecord::Base.sanitize_sql_for_conditions(['AND moderation_logs.reference_type=?', scope.model_name.name]) }
        #{ ActiveRecord::Base.sanitize_sql_for_conditions(['AND moderation_logs.message=?', message]) if message }
    )
    scope
      .where('moderation_logs.id' => nil)
      .joins(join_sql)
  end
end
