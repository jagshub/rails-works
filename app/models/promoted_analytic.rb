# frozen_string_literal: true

# == Schema Information
#
# Table name: promoted_analytics
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  promoted_product_id :integer
#  ip_address          :string
#  track_code          :string
#  source              :string
#  user_action         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  nonce               :string
#  user_agent          :string
#
# Indexes
#
#  index_promoted_analytics_on_promoted_product_id  (promoted_product_id)
#  index_promoted_analytics_on_track_code           (track_code)
#  index_promoted_analytics_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (promoted_product_id => promoted_products.id)
#  fk_rails_...  (user_id => users.id)
#

class PromotedAnalytic < ApplicationRecord
  # NOTE(DZ): PromotedAnalytic is deprecated. Use `Ads::Interaction` instead
  # Deprecation date 2020-01-04
  def readonly?
    true
  end

  belongs_to :user, optional: true
  belongs_to :promoted_product, inverse_of: :analytics, optional: true

  enum user_action: {
    click: 'click',
    close: 'close',
    view: 'view',
  }

  scope :closes_by, lambda { |user, track_code|
    scope = where(user_action: :close)
    scope = scope.where(user: user) if user.present?
    scope = scope.where(track_code: track_code) if track_code.present?
    scope
  }
end
