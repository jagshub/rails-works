# frozen_string_literal: true

# == Schema Information
#
# Table name: team_members
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)        not null
#  product_id        :bigint(8)        not null
#  referrer_type     :string           not null
#  referrer_id       :bigint(8)        not null
#  role              :string           not null
#  position          :string
#  team_email        :string
#  status            :string           default("active"), not null
#  status_changed_at :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_team_members_on_product_id              (product_id)
#  index_team_members_on_referrer                (referrer_type,referrer_id)
#  index_team_members_on_user_id_and_product_id  (user_id,product_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (user_id => users.id)
#
class Team::Member < ApplicationRecord
  include Namespaceable
  HasEmailField.define self, field_name: :team_email, uniqueness: { scope: :product_id }, allow_nil: true

  REFERRER_TYPES = [Team::Invite, Team::Request].freeze

  audited except: %i(created_at updated_at)

  belongs_to :user, inverse_of: :team_memberships
  belongs_to :product, inverse_of: :team_members
  belongs_to_polymorphic :referrer, inverse_of: :team_member, dependent: :destroy, allowed_classes: REFERRER_TYPES

  enum status: {
    active: 'active',
    inactive: 'inactive',
  }

  enum role: {
    member: 'member',
    owner: 'owner',
  }

  validates :status, presence: true
  validates :role, presence: true
  validates :referrer_id, uniqueness: { scope: %i(product_id referrer_type) }
end
