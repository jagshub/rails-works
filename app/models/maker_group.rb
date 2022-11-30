# frozen_string_literal: true

# == Schema Information
#
# Table name: maker_groups
#
#  id                    :integer          not null, primary key
#  name                  :string           not null
#  kind                  :integer          default("public_access"), not null
#  completed_goals_count :integer          default(0), not null
#  goals_count           :integer          default(0), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  description           :string           not null
#  members_count         :integer          default(0), not null
#  pending_members_count :integer          default(0), not null
#  tagline               :string           not null
#  last_activity_at      :datetime
#  instructions_html     :text
#  discussions_count     :integer          default(0), not null
#
# Indexes
#
#  index_maker_groups_on_kind              (kind)
#  index_maker_groups_on_last_activity_at  (last_activity_at)
#

class MakerGroup < ApplicationRecord
  include ChronologicalOrder
  include ExplicitCounterCache
  include SlateFieldOverride
  include Discussable

  slate_field :instructions, mode: :url_and_username

  MAIN_ID = 1

  # NOTE(DZ): ids come from production
  IOS_BETA = 661
  ANDROID_BETA = 662

  MAX_LENGH_DESCRIPTION = 500
  MAX_LENGTH_NAME = 45
  MAX_LENGTH_TAGLINE = 160

  has_many :goals, foreign_key: :maker_group_id, inverse_of: :group, dependent: :destroy
  has_many :all_members, class_name: 'MakerGroupMember', foreign_key: :maker_group_id, inverse_of: :group, dependent: :destroy
  has_many :members, -> { accepted }, class_name: 'MakerGroupMember', foreign_key: :maker_group_id, inverse_of: :group
  has_many :member_users, class_name: 'User', through: :members, source: :user
  has_many :owners, -> { accepted.owner }, class_name: 'MakerGroupMember', foreign_key: :maker_group_id, inverse_of: :group
  has_many :maker_activities, inverse_of: :maker_group, dependent: :delete_all

  has_one :makers_festival_edition, class_name: '::MakersFestival::Edition', inverse_of: :maker_group

  enum kind: {
    public_access: 0,
    private_access: 1,
    protected_access: 2,
    hidden_access: 3,
  }

  explicit_counter_cache :completed_goals_count, -> { goals.completed }
  explicit_counter_cache :members_count, -> { members }
  explicit_counter_cache :pending_members_count, -> { all_members.pending }

  validates :description, presence: true, length: { maximum: MAX_LENGH_DESCRIPTION }
  validates :kind, inclusion: { in: kinds.keys }
  validates :name, presence: true, length: { maximum: MAX_LENGTH_NAME }
  validates :tagline, presence: true, length: { maximum: MAX_LENGTH_TAGLINE }

  scope :accessible, -> { where(kind: %i(public_access protected_access private_access)) }
  scope :by_activity, -> { order('maker_groups.last_activity_at DESC NULLS LAST') }
  scope :by_kind, -> { order(Arel.sql(%(CASE WHEN maker_groups.id = #{ MAIN_ID } THEN 1 END))) }

  scope :main, -> { find(MAIN_ID) }

  class << self
    def ios_beta
      find_by(id: IOS_BETA)
    end

    def android_beta
      find_by(id: ANDROID_BETA)
    end
  end

  def accessible?
    public_access? || protected_access? || private_access?
  end

  def main?
    id == MAIN_ID
  end

  def to_param
    "#{ id }-#{ name.parameterize }"
  end
end
