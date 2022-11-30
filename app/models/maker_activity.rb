# frozen_string_literal: true

# == Schema Information
#
# Table name: maker_activities
#
#  id             :bigint(8)        not null, primary key
#  activity_type  :integer          default(NULL), not null
#  user_id        :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  subject_type   :string           not null
#  subject_id     :bigint(8)        not null
#  hidden_at      :datetime
#  maker_group_id :bigint(8)        not null
#
# Indexes
#
#  index_maker_activities_on_created_at                   (created_at)
#  index_maker_activities_on_hidden_at                    (hidden_at)
#  index_maker_activities_on_maker_group_id               (maker_group_id)
#  index_maker_activities_on_subject_id_and_subject_type  (subject_id,subject_type)
#  index_maker_activities_on_subject_type_and_subject_id  (subject_type,subject_id)
#  index_maker_activities_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (maker_group_id => maker_groups.id)
#  fk_rails_...  (user_id => users.id)
#

class MakerActivity < ApplicationRecord
  include ChronologicalOrder

  HasTimeAsFlag.define self, :hidden, enable: :hide, disable: :show

  belongs_to :user, inverse_of: :maker_activities
  belongs_to :subject, polymorphic: true, inverse_of: :maker_activities
  belongs_to :maker_group, inverse_of: :maker_activities

  enum activity_type: {
    discussion_created: 2,
  }

  validates :activity_type, presence: true

  scope :feed, -> { includes(:subject).not_hidden }
  scope :not_spam, -> { joins(:user).where('users.role NOT IN (?)', User.roles.slice(*Spam::User::NON_CREDIBLE_ROLES).values) }
end
