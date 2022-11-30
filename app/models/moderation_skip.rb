# frozen_string_literal: true

# == Schema Information
#
# Table name: moderation_skips
#
#  id           :bigint(8)        not null, primary key
#  subject_type :string           not null
#  subject_id   :bigint(8)        not null
#  user_id      :bigint(8)        not null
#  message      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_moderation_skips_on_subject           (subject_type,subject_id)
#  index_moderation_skips_on_subject_and_user  (subject_id,subject_type,user_id) UNIQUE
#  index_moderation_skips_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ModerationSkip < ApplicationRecord
  belongs_to :subject, polymorphic: true
  belongs_to :user, inverse_of: :moderation_skips

  def self.exclude_skipped(scope, user_id:)
    join_sql = %(
        LEFT JOIN moderation_skips ON
        moderation_skips.subject_id = #{ scope.table_name }.id
        #{ ActiveRecord::Base.sanitize_sql_for_conditions([
                                                            'AND moderation_skips.subject_type = ?
                                                            AND moderation_skips.user_id = ?',
                                                            scope.model_name.name, Integer(user_id)
                                                          ]) }
    )
    scope
      .where('moderation_skips.id' => nil)
      .joins(join_sql)
  end
end
