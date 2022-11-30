# frozen_string_literal: true

# == Schema Information
#
# Table name: founder_club_access_requests
#
#  id                  :integer          not null, primary key
#  email               :string           not null
#  user_id             :integer
#  deal_id             :integer
#  invite_code         :string           not null
#  received_code_at    :datetime
#  used_code_at        :datetime
#  subscribed_at       :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  source              :integer          default("waitlist"), not null
#  invited_by_user_id  :integer
#  expire_at           :datetime
#  payment_discount_id :bigint(8)
#
# Indexes
#
#  index_founder_club_access_requests_on_deal_id              (deal_id)
#  index_founder_club_access_requests_on_email                (email) UNIQUE
#  index_founder_club_access_requests_on_invite_code          (invite_code) UNIQUE
#  index_founder_club_access_requests_on_invited_by_user_id   (invited_by_user_id) WHERE (invited_by_user_id IS NOT NULL)
#  index_founder_club_access_requests_on_payment_discount_id  (payment_discount_id)
#  index_founder_club_access_requests_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (deal_id => founder_club_deals.id)
#  fk_rails_...  (invited_by_user_id => users.id)
#  fk_rails_...  (payment_discount_id => payment_discounts.id)
#  fk_rails_...  (user_id => users.id)
#

class FounderClub::AccessRequest < ApplicationRecord
  include Namespaceable

  HasEmailField.define self
  HasUniqueCode.define self, field_name: :invite_code, length: 6
  HasTimeAsFlag.define self, :received_code
  HasTimeAsFlag.define self, :used_code
  HasTimeAsFlag.define self, :subscribed

  belongs_to :user, optional: true, inverse_of: :founder_club_access_request
  belongs_to :deal, optional: true, inverse_of: :access_requests
  belongs_to :invited_by_user, class_name: 'User', optional: true, inverse_of: :founder_club_referrals

  belongs_to :payment_discount, class_name: 'Payment::Discount', inverse_of: :access_requests, optional: true

  validates :invited_by_user, presence: true, if: :referral?

  enum source: %i(waitlist referral promo)

  attr_readonly :email, :user_id, :deal_id

  FC_EARLY_DISCOUNT_CODE = 'FCEARLY'

  def payment_discount_with_fallback
    # NOTE(DZ): If access_request does not have a discount reference, use one
    # with code 'FCEARLY'
    @payment_discount_with_fallback ||= payment_discount || ::Payment::Discount.active.find_by(code: FC_EARLY_DISCOUNT_CODE)
  end
end
