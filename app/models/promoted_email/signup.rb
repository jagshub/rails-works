# frozen_string_literal: true

# == Schema Information
#
# Table name: promoted_email_signups
#
#  id                         :bigint(8)        not null, primary key
#  email                      :string           not null
#  promoted_email_campaign_id :bigint(8)        not null
#  user_id                    :bigint(8)
#  ip_address                 :string
#  track_code                 :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_promoted_email_email_campaign_id                      (email,promoted_email_campaign_id) UNIQUE
#  index_promoted_email_signups_on_promoted_email_campaign_id  (promoted_email_campaign_id)
#  index_promoted_email_user_campaign_id                       (user_id,promoted_email_campaign_id) UNIQUE WHERE (user_id IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (promoted_email_campaign_id => promoted_email_campaigns.id)
#  fk_rails_...  (user_id => users.id)
#

class PromotedEmail::Signup < ApplicationRecord
  # NOTE(DZ): PromotedEmail is deprecated
  def readonly?
    true
  end

  include Namespaceable

  before_validation :normalize_email

  validates :email, presence: true, email_format: true

  belongs_to :promoted_email_campaign, class_name: '::PromotedEmail::Campaign', inverse_of: :signups
  belongs_to :user, inverse_of: :promoted_email_signups, optional: true
  after_create :refresh_counters
  after_destroy :refresh_counters

  private

  def refresh_counters
    # NOTE(naman): always refresh campaign signups count before config counts
    promoted_email_campaign.refresh_signups_count
    promoted_email_campaign.campaign_config&.refresh_signups_count
  end

  def normalize_email
    self.email = email.presence && email.downcase
  end
end
