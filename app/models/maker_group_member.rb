# frozen_string_literal: true

# == Schema Information
#
# Table name: maker_group_members
#
#  id               :integer          not null, primary key
#  maker_group_id   :integer          not null
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  state            :integer          default("pending"), not null
#  role             :integer          default("maker"), not null
#  assessed_at      :datetime
#  assessed_user_id :integer
#  last_activity_at :datetime
#
# Indexes
#
#  index_maker_group_members_on_assessed_at                 (assessed_at)
#  index_maker_group_members_on_assessed_user_id            (assessed_user_id)
#  index_maker_group_members_on_last_activity_at            (last_activity_at)
#  index_maker_group_members_on_maker_group_id              (maker_group_id)
#  index_maker_group_members_on_role                        (role)
#  index_maker_group_members_on_state                       (state)
#  index_maker_group_members_on_user_id_and_maker_group_id  (user_id,maker_group_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (maker_group_id => maker_groups.id)
#  fk_rails_...  (user_id => users.id)
#

class MakerGroupMember < ApplicationRecord
  belongs_to :group,
             class_name: 'MakerGroup',
             foreign_key: 'maker_group_id',
             inverse_of: :members

  belongs_to :user

  belongs_to :assessed_by,
             class_name: 'User',
             foreign_key: :assessed_user_id,
             inverse_of: false,
             optional: true

  has_many :goals, ->(member) { where(user_id: member.user_id) }, through: :group

  enum role: {
    maker: 0,
    owner: 1,
  }

  enum state: {
    pending: 0,
    accepted: 1,
    declined: 2,
  }

  validates :user_id, uniqueness: { scope: :maker_group_id }

  after_commit :refresh_counters, only: %i(create destroy)

  scope :accessible, -> { joins(:group).merge(MakerGroup.accessible) }
  scope :by_activity, -> { order('maker_group_members.last_activity_at DESC NULLS LAST') }

  scope :by_date, lambda { |order = :desc|
    order(
      arel_table[:assessed_at].public_send(order),
    ).order(
      arel_table[:id].public_send(order),
    )
  }

  def assessed?
    assessed_by.present?
  end

  private

  def refresh_counters
    group.refresh_members_count
    group.refresh_pending_members_count
    user.refresh_maker_group_memberships_count
  end
end
