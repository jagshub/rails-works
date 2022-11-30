# frozen_string_literal: true

# == Schema Information
#
# Table name: team_invites
#
#  id                :bigint(8)        not null, primary key
#  product_id        :bigint(8)        not null
#  referrer_id       :bigint(8)
#  identity_type     :string           not null
#  email             :string
#  user_id           :bigint(8)
#  code              :string           not null
#  code_expires_at   :datetime         not null
#  status            :string           default("pending"), not null
#  status_changed_at :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_flags_count  :integer          default(0), not null
#
# Indexes
#
#  index_team_invites_on_code         (code)
#  index_team_invites_on_product_id   (product_id)
#  index_team_invites_on_referrer_id  (referrer_id)
#  index_team_invites_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (referrer_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
class Team::Invite < ApplicationRecord
  include Namespaceable
  include UserFlaggable
  HasUniqueCode.define self, field_name: :code, length: 14, expires_in: 2.weeks

  audited associated_with: :product, except: %i(created_at updated_at)

  before_save :set_status_changed_at

  belongs_to :user, optional: true, inverse_of: :team_invites
  belongs_to :referrer, class_name: 'User', inverse_of: :sent_team_invites
  belongs_to :product, inverse_of: :team_invites
  has_one :team_member, class_name: 'Team::Member', as: :referrer, dependent: :destroy, inverse_of: :referrer

  enum status: {
    pending: 'pending',
    accepted: 'accepted',
    rejected: 'rejected',
    expired: 'expired',
  }

  enum identity_type: {
    email: 'email',
    user: 'user',
  }

  validates :referrer, presence: true
  validates :status, presence: true
  validates :identity_type, presence: true

  # TODO(DT): Add a smarter uniqueness validator, considering the invite status and the cooldown period.
  validates :email, presence: true, uniqueness: { scope: :product_id }, if: -> { identity_type == 'email' }
  validates :user, presence: true, uniqueness: { scope: :product_id }, if: -> { identity_type == 'user' }

  # TODO(DT): Will be removed in the Invites PR.
  def expired?
    code_expires_at.past?
  end

  private

  def set_status_changed_at
    self.status_changed_at = Time.current if status_changed?
  end
end
