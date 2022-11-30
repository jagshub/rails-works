# frozen_string_literal: true

# == Schema Information
#
# Table name: users_deleted_karma_logs
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)        not null
#  subject_type :string           not null
#  karma_value  :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_users_deleted_karma_logs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Users::DeletedKarmaLog < ApplicationRecord
  include Namespaceable
  belongs_to :user

  # Note(TC): Any given subject_type should only associate with a given user_id once.
  # This prevents duplicate karma logs being created for users.
  validates :user_id, uniqueness: { scope: :subject_type,
                                    message: 'should only have one record for any given subject_type' }

  # Note(TC): This is the "Tag" of some existing model that used to carry
  # karma for a user. This tag doesnt have to match a real model,
  # as it is just a unique identifer to determine where points came from. To see
  # the process for how to sunset a Karma related feature view the docs:
  # https://www.notion.so/teamhome1431/Keep-Karma-From-Deprecated-Features-2f64d8a4163d41d9a9b4c74de8cc7fde
  DEPRECATED_MODEL_TAGS = [
    'Goal',
  ].freeze

  scope :deprecated, -> { where(subject_type: DEPRECATED_MODEL_TAGS) }
end
