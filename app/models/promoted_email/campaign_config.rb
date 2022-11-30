# frozen_string_literal: true

# == Schema Information
#
# Table name: promoted_email_campaign_configs
#
#  id            :bigint(8)        not null, primary key
#  campaign_name :string           not null
#  signups_cap   :integer          default(-1), not null
#  signups_count :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PromotedEmail::CampaignConfig < ApplicationRecord
  # NOTE(DZ): PromotedEmail is deprecated
  def readonly?
    true
  end

  include Namespaceable

  validates :campaign_name, presence: true, uniqueness: true

  has_many :campaigns, class_name: 'PromotedEmail::Campaign', inverse_of: :campaign_config, primary_key: 'campaign_name', foreign_key: 'campaign_name'

  def refresh_signups_count
    # NOTE(naman): always refresh each campaign signups count before refreshing this
    update_columns signups_count: campaigns.sum(:signups_count), updated_at: Time.current
  end
end
