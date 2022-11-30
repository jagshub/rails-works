# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_leads
#
#  id                          :integer          not null, primary key
#  email                       :string           not null
#  name                        :string
#  status                      :integer          default("lead"), not null
#  project_name                :string
#  project_tagline             :string
#  project_phase               :integer          default("pre_beta"), not null
#  launch_period               :integer          default("unknown"), not null
#  user_id                     :integer
#  ship_instant_access_page_id :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  team_size                   :integer          default("unknown"), not null
#  signup_goal                 :string
#  incorporated                :boolean          default(FALSE)
#  request_stripe_atlas        :boolean          default(FALSE)
#  signup_design               :string
#
# Indexes
#
#  index_ship_leads_on_ship_instant_access_page_id  (ship_instant_access_page_id)
#  index_ship_leads_on_user_id                      (user_id)
#

class ShipLead < ApplicationRecord
  HasEmailField.define self

  belongs_to :user, optional: true
  belongs_to :ship_instant_access_page, optional: true

  has_one :ship_subscription, required: false, through: :user

  before_validation :normalize_email

  enum status: {
    lead: 0,
    user: 100,
    customer: 200,
  }

  enum launch_period: {
    unknown: 0,
    one_week_from_now: 100,
    one_month_from_now: 200,
    three_months_from_now: 300,
    more_than_three_months_from_now: 400,
  }

  enum project_phase: {
    pre_beta: 0,
    in_beta: 100,
    already_public: 200,
  }

  enum team_size: {
    unknown: 0,
    just_me: 100,
    two_to_five: 200,
    six_to_twenty: 300,
    twenty_plus: 400,
  }, _prefix: :team_size
end
